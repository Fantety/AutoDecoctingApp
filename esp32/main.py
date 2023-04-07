from stepper import Steppers
import time
import utime
import ble
import bluetooth
from machine import I2C,Pin,PWM,Timer,SoftI2C
from ssd1306 import SSD1306_I2C
import onewire,ds18x20 #温度传感器相关模块
from mthread import Task

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

stepper_count = 0
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


KEY=Pin(0,Pin.IN,Pin.PULL_UP) #构建KEY对象
state=0  #LED引脚状态

#初始化蓝牙模块
carble = bluetooth.BLE()
p = ble.BLESimplePeripheral(carble)
aa=carble.config('mac')

#构建继电器对象,默认断开
relay=Pin(32,Pin.OUT,value=1)


#流程计时相关
#下入先煎1
#浸泡2
SOAK_TIME = 10
#烧开3
#恒温4
CONSTANT_TEMP = 10
CONSTANT_TIME = 10
#加入中煎5
#烧开6
#恒温7
#下入后煎8
CONCENTRATION_TIME = 10
#浓缩9
#结束11

STEPPER_VALUE = 12.5
is_active = False
order = 0
is_boil = 0
time_count = 0
time_contin_count = 0
timer_main = Timer(0)
#timer_temp = Timer(1)
timer_oneshot_task = Timer(2)
timer_contin_task = Timer(3)

def start_decocting(timer_main):
    global time_count
    global is_active
    time_count += 1
    if is_active:
        if order == 1 or order == 5 or order == 8:
            timer_oneshot_task.init(period=1000, mode=Timer.ONE_SHOT,callback=oneshot_task)
            pass
        elif order == 2 or order == 3 or order == 4 or order == 6 or order == 7 or order == 8 or order == 10:
            timer_contin_task.init(period=1000, mode=Timer.PERIODIC,callback=contin_task)
            pass
        pass

def oneshot_task(timer_oneshot_task):
    global is_active
    global order
    global time_contin_count
    time_contin_count = 0
    is_active = False
    rotate_stepper()
    order += 1
    is_active = True
    timer_oneshot_task.deinit()
    pass

def contin_task(timer_contin_task):
    global is_active
    global time_contin_count
    global order
    is_active = False
    time_contin_count += 1
    if order == 2:
        if time_contin_count >= SOAK_TIME:
            time_contin_count = 0
            is_active = True
            order += 1
            timer_contin_task.deinit()
            pass 
        pass
    elif order == 3 or order == 6:
        relay.value(0)
        if is_boil == 1:
            time_contin_count = 0
            is_active = True
            order += 1
            timer_contin_task.deinit()
            pass
    elif order == 4 or order == 7:
        if time_contin_count >= CONSTANT_TIME:
            time_contin_count = 0
            is_active = True
            order += 1
            timer_contin_task.deinit()
            pass 
        pass
    elif order == 9:
        relay.value(0)
        if time_contin_count >= CONCENTRATION_TIME:
            time_contin_count = 0
            is_active = True
            order += 1
            timer_contin_task.deinit()
            pass 
        pass
    elif order == 10:
        quit_()
    pass

def rotate_stepper():
    global stepper_count
    s.Step(0,STEPPER_VALUE,0,4,50)
    stepper_count += STEPPER_VALUE


#温度传感器相关模块初始化
ow= onewire.OneWire(Pin(22)) #使能单总线
ds = ds18x20.DS18X20(ow) #传感器是 DS18B20
rom = ds.scan() #扫描单总线上的传感器地址，支持多个传感器同时连接


def start_():
    global is_active
    global order
    global info
    order += 1
    is_active = True
    timer_main.init(period=1000, mode=Timer.PERIODIC,callback=start_decocting)
    #timer_temp.init(period=1000, mode=Timer.PERIODIC,callback=temp_get)
    info = 'start'
    oled.text("start",0,30)


def quit_():
    global is_active
    global time_count
    global stepper_count
    global time_contin_count
    global order
    global info
    is_active = False
    order = 0
    timer_main.deinit()
    #timer_temp.deinit()
    relay.value(1)
    time_count = 0
    time_contin_count = 0
    timer_contin_task.deinit()
    timer_oneshot_task.deinit()
    s.Step(0,stepper_count,1,4,50)
    stepper_count = 0
    info = 'quit'
    oled.text("quit",0,30)


#蓝牙接受数据处理
def on_rx(v):
    global order
    global is_active
    global info
    Beep.freq(500)
    time.sleep_ms(300)
    Beep.freq(0)
    oled.fill(0)
    #print(v[0])
    #print("Receive_data:", str(v))
    if v==b'start':
        if info != 'start':
            start_()
    elif v==b'pause':
        global info
        info = 'pause'
        oled.text("pause",0,30)
    elif v==b'quit':
        global info
        if info == 'start':
            quit_()
    #p[浸泡时间],[恒温温度],[恒温时间],[浓缩时间],[电机步距]
    elif str(v)[0] == 'p':
        p_list = str(v)[1:].split(',')
        global STEPPER_VALUE
        global SOAK_TIME
        global CONSTANT_TEMP
        global CONCENTRATION_TIME
        global CONSTANT_TIME
        SOAK_TIME = int(p_list[0])
        CONSTANT_TEMP = int(p_list[1])
        CONSTANT_TIME = int(p_list[2])
        CONCENTRATION_TIME = int(p_list[3])
        STEPPER_VALUE = int(p_list[4])
        pass
p.on_write(on_rx)


#温度传感器数据处理
def temp_get():
    ds.convert_temp()
    global temp
    global is_boil
    temp = ds.read_temp(rom[0]) #温度显示,rom[0]为第 1 个 DS18B20
    #OLED 数据显示
    if temp > 98.0:
        is_boil = 1
    else:
        is_boil = 0
    oled.show()
temp_get_task = Task(temp_get,1)
temp_get_task.start()


#遥控器中断处理函数
def fun(IR):
    global info
    key = getkey()
    if key != None and key != 'REPEAT':
        Beep.freq(500)
        time.sleep_ms(300)
        Beep.freq(0)
        if info != 'start' and key == 69:
            start_()
        if info == 'start' and key == 70:
            quit_()
IR.irq(fun,Pin.IRQ_FALLING) #定义中断，下降沿触发


def ble_send():
    if p.is_connected():
        p.send('c'+str('%.2f'%temp)+';'+'t'+str(time_count)+';'+'l'+str(order)+';s'+info)
ble_send_task = Task(ble_send,1)
ble_send_task.start()

oneshot_param = 0
while 1: 
    oled.text('AutoDecocting', 0, 0)
    oled.text('Temp: '+str('%.2f'%temp)+' C',0,15)     
    oled.text(info,0,30)
    if p.is_connected() and oneshot_param == 0:
        led.value(1)
        oled.text("APP connected",0,45)
        oneshot_param = 1
    elif not p.is_connected() and oneshot_param == 1:
        led.value(0)
        oled.text("APP disconnected",0,45)
        oneshot_param = 0
    oled.show()
    utime.sleep_ms(100)
    oled.fill(0)#清屏背景黑色

