from stepper import Steppers
import time
import utime
import ble
import bluetooth
from machine import I2C,Pin,PWM,Timer,SoftI2C
from ssd1306 import SSD1306_I2C
import onewire,ds18x20 #温度传感器相关模块

#遥控器处理
IR = Pin(21, Pin.IN, Pin.PULL_UP)
def getkey():
    global IR
    if (IR.value() == 0):
        count = 0
        while ((IR.value() == 0) and (count < 100)): #9ms
            count += 1
            time.sleep_us(100)
        if(count < 10):
            return None
        count = 0
        while ((IR.value() == 1) and (count < 50)): #4.5ms
            count += 1
            time.sleep_us(100)
        idx = 0
        cnt = 0
        data = [0,0,0,0]
        for i in range(0,32):
            count = 0
            while ((IR.value() == 0) and (count < 10)):    #0.56ms
                count += 1
                time.sleep_us(100)
            count = 0
            while ((IR.value() == 1) and (count < 20)):   #0: 0.56mx
                count += 1                                #1: 1.69ms
                time.sleep_us(100)
            if count > 7:
                data[idx] |= 1<<cnt
            if cnt == 7:
                cnt = 0
                idx += 1
            else:
                cnt += 1
        if data[0]+data[1] == 0xFF and data[2]+data[3] == 0xFF:  #check
            return data[2]
        else:
            return("REPEAT")


temp = 0
info = 'none'
#构建I2C对象
i2c1=SoftI2C(sda=Pin(16), scl=Pin(17))
#i2c1_2=SoftI2C(sda=Pin(21), scl=Pin(22))
#构建2路42步进电机对象
s=Steppers(i2c1)
#步距角1.8，转一圈所用的脉冲数为 n=360/1.8=200个脉冲。
#200/4 = 50
#42步进电机对象使用用法，详情参看stepper.py文件
#
#s.Step(index, steps=0, direction=1,mode=4, interval=2)
#index: 0~1表示2路42步进电机
#steps: 转动步数
#direction：方向,1为正转，0为反转
#mode: 4表示4拍，8表示八拍
#interval：每拍间隔时间，单位为ms

#蓝牙指示灯
led=Pin(2,Pin.OUT)
#初始化oled屏相关模块
i2c = I2C(sda=Pin(13),scl=Pin(14))
oled = SSD1306_I2C(128,64, i2c, addr=0x3c)

#初始化蜂鸣器PWM
Beep = PWM(Pin(25), freq=0, duty=512)


LED=Pin(2,Pin.OUT) #构建LED对象,开始熄灭
KEY=Pin(0,Pin.IN,Pin.PULL_UP) #构建KEY对象
state=0  #LED引脚状态

#初始化蓝牙模块
carble = bluetooth.BLE()
p = ble.BLESimplePeripheral(carble)
aa=carble.config('mac')

#构建继电器对象,默认断开
relay=Pin(32,Pin.OUT,value=1)

ble_send_timer = Timer(1)

#流程计时相关
start_20 = 0
order = 0
is_boil = 0
time_count = 0
time_count_20 = 0
time_count_5 = 0
start_5 = 0
timer_main = Timer(0)
tim = Timer(-1)
def start_decocting(timer_main):
    global order
    global time_count_20
    global time_count_5
    global time_count
    global start_5
    global start_20
    global temp
    if start_20 == 1:
        time_count_20 += 1
    if start_5 == 1:
        time_count_5 += 1
    if time_count == 0:
        order = 1
        if p.is_connected():
            p.send('l1')
        s.Step(0,12.5,0,4,50)
        #此处开始煎药的操作
        #先煎药放下
        #开始浸泡
        pass
    elif order == 1 and time_count == 40*60:
        order = 2
        if p.is_connected():
            p.send('l2')
        #继电器通电
        #开始先煎
        #加热至100
        pass
    elif order == 2 and is_boil == 1:
        order = 3
        time_count_20 = 0
        start_20 = 1
        if p.is_connected():
            p.send('l3')
        #继电器通电
        #70-80恒温20分钟
        pass
    elif order == 3 and time_count_20 == 20*60:
        order = 4
        start_20 = 0
        time_count_20 = 0
        if p.is_connected():
            p.send('l4')
        #中煎药放下
        #加热至100
        pass
    elif order == 4 and is_boil == 1:
        order = 5
        time_count_20 = 0
        start_20 = 1
        if p.is_connected():
            p.send('l5')
        #继电器通电
        #70-80恒温20分钟
        pass
    elif order == 5 and time_count_20 == 20*60:
        order = 6
        start_20 = 0
        time_count_20 = 0
        if p.is_connected():
            p.send('l6')
        #加热至100
        #浓缩
        pass
    elif order == 6:
        order = 7
        if p.is_connected():
            p.send('l7')
        #下入后煎
        pass
    elif order == 7:
        order = 8
        time_count_5 = 0
        start_5 = 1
        if p.is_connected():
            p.send('l8')
        #继电器通电
        #加热5-10分钟
        pass
    elif order == 8:
        order = 0
        time_count_5 = 0
        start_5 = 0
        time_count_20 = 0
        start_20 = 0
        timer_main.deinit()
        if p.is_connected():
            p.send('l9')
        #继电器通电
        #加热5-10分钟
        pass
    time_count += 1


#温度传感器相关模块初始化
ow= onewire.OneWire(Pin(22)) #使能单总线
ds = ds18x20.DS18X20(ow) #传感器是 DS18B20
rom = ds.scan() #扫描单总线上的传感器地址，支持多个传感器同时连接


#蓝牙接受数据处理
def on_rx(v):
    Beep.freq(500)
    time.sleep_ms(500)
    Beep.deinit()
    oled.fill(0)
    #print(v[0])
    #print("Receive_data:", str(v))
    if v==b'start':
        global info
        if info != 'start':
            global timer_main
            global tim
            timer_main.init(period=1000, mode=Timer.PERIODIC,callback=start_decocting)
            tim.init(period=2000, mode=Timer.PERIODIC,callback=temp_get)
            info = 'start'
            oled.text("start",0,30)
    elif v==b'pause':
        global info
        info = 'pause'
        oled.text("pause",0,30)
    elif v==b'quit':
        global info
        if info == 'start':
            global timer_main
            timer_main.deinit()
            tim.deinit()
            s.Step(0,100,0)
            info = 'quit'
            oled.text("quit",0,30)
p.on_write(on_rx)


#温度传感器数据处理

def temp_get(tim):
    ds.convert_temp()
    global temp
    temp = ds.read_temp(rom[0]) #温度显示,rom[0]为第 1 个 DS18B20
    #OLED 数据显示
    oled.fill(0)#清屏背景黑色
    oled.text('AutoDecocting', 0, 0)
    oled.text('Temp: '+str('%.2f'%temp)+' C',0,15)
    if temp > 98.0:
        global is_boil
        is_boil = 1
    else:
        global is_boil
        is_boil = 0
    oled.show()
#开启 RTOS 定时器，编号为-1

#定时器周期为 1000ms




#遥控器中断处理函数
def fun(IR):
    oled.fill(0)
    global info
    key = getkey()
    if key != None and key != 'REPEAT':
        if info != 'start' and key == 69:
            global timer_main
            global tim
            timer_main.init(period=1000, mode=Timer.PERIODIC,callback=start_decocting)
            tim.init(period=2000, mode=Timer.PERIODIC,callback=temp_get)
            info = 'start'
            oled.text("start",0,30)
        if info == 'start' and key == 70:
            global timer_main
            global tim
            timer_main.deinit()
            tim.deinit()
            info = 'pause'
            oled.text("pause",0,30)
    print(key)
IR.irq(fun,Pin.IRQ_FALLING) #定义中断，下降沿触发


def ble_send(ble_send_timer):
    if p.is_connected():
        p.send('c'+str('%.2f'%temp)+';'+'t'+str(time_count))


oneshot_param = 0
while 1:      
    oled.text(info,0,30)
    if p.is_connected() and oneshot_param == 0:
        led.value(1)
        oled.text("APP connected",0,45)
        ble_send_timer.init(period=1000, mode=Timer.PERIODIC,callback=ble_send)
        oneshot_param = 1
    elif not p.is_connected() and oneshot_param == 1:
        led.value(0)
        oled.text("APP disconnected",0,45)
        ble_send_timer.deinit()
        oneshot_param = 0
    oled.show()
    utime.sleep_ms(100)
