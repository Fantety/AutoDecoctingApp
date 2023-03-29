#ifndef TEXTSPEECH_H
#define TEXTSPEECH_H

#include <QObject>

class textspeech : public QObject
{
    Q_OBJECT
public:
    explicit textspeech(QObject *parent = nullptr);

signals:

};

#endif // TEXTSPEECH_H
