// The MIT License (MIT)
//
// Copyright (c) Itay Grudev 2015 - 2020
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//
//  W A R N I N G !!!
//  -----------------
//
// This file is not part of the SingleApplication API. It is used purely as an
// implementation detail. This header file may change from version to
// version without notice, or may even be removed.
//

#ifndef SINGLEAPPLICATION_PRIVATE_H
#define SINGLEAPPLICATION_PRIVATE_H
/* ************************************************************************** */

#include "SingleApplication.h"

class QSharedMemory;
class QLocalServer;
class QLocalSocket;

struct InstancesInfo {
    bool primary;
    quint32 secondary;
    qint64 primaryPid;
    char primaryUser[128];
    quint16 checksum; // Must be the last field
};

struct ConnectionInfo {
    qint64 msgLen = 0;
    quint32 instanceId = 0;
    quint8 stage = 0;
};

/* ************************************************************************** */

class SingleApplicationPrivate : public QObject {
Q_OBJECT
public:
    enum ConnectionType : quint8 {
        InvalidConnection = 0,
        NewInstance = 1,
        SecondaryInstance = 2,
        Reconnect = 3
    };
    enum ConnectionStage : quint8 {
        StageInitHeader = 0,
        StageInitBody = 1,
        StageConnectedHeader = 2,
        StageConnectedBody = 3,
    };
    Q_DECLARE_PUBLIC(SingleApplication)

    SingleApplicationPrivate( SingleApplication *q_ptr );
    ~SingleApplicationPrivate() override;

    static QString getUsername();
    void genBlockServerName();
    void initializeMemoryBlock() const;
    void startPrimary();
    void startSecondary();
    bool connectToPrimary( int msecs, ConnectionType connectionType );
    quint16 blockChecksum() const;
    qint64 primaryPid() const;
    QString primaryUser() const;
    bool isFrameComplete(QLocalSocket *sock);
    void readMessageHeader(QLocalSocket *socket, ConnectionStage nextStage);
    void readInitMessageBody(QLocalSocket *socket);
    void writeAck(QLocalSocket *sock);
    bool writeConfirmedFrame(int msecs, const QByteArray &msg);
    bool writeConfirmedMessage(int msecs, const QByteArray &msg);
    static void randomSleep();
    void addAppData(const QString &data);
    QStringList appData() const;

    SingleApplication *q_ptr;
    QSharedMemory *memory;
    QLocalSocket *socket;
    QLocalServer *server;
    quint32 instanceNumber;
    QString blockServerName;
    SingleApplication::Options options;
    QMap<QLocalSocket*, ConnectionInfo> connectionMap;
    QStringList appDataList;

public Q_SLOTS:
    void slotConnectionEstablished();
    void slotDataAvailable( QLocalSocket*, quint32 );
    void slotClientConnectionClosed( QLocalSocket*, quint32 );
};



#if !QT_CONFIG(sharedmemory) ///////////////////////////////////////////////////
#include <QNativeIpcKey>
class QSharedMemory : public QObject
{
    Q_OBJECT

public:
    enum AccessMode
    {
        ReadOnly,
        ReadWrite
    };
    enum SharedMemoryError
    {
        NoError,
        PermissionDenied,
        InvalidSize,
        KeyError,
        AlreadyExists,
        NotFound,
        LockError,
        OutOfResources,
        UnknownError
    };

    QSharedMemory(QObject *parent = nullptr) { Q_UNUSED(parent) }
    QSharedMemory(const QString &key, QObject *parent = nullptr) { Q_UNUSED(key); Q_UNUSED(parent); }
    QSharedMemory(const QNativeIpcKey &key, QObject *parent = nullptr) { Q_UNUSED(key); Q_UNUSED(parent); }
    ~QSharedMemory() {}

    void setKey(const QString &) {}
    QString key() const { return QString(); }
    void setNativeKey(const QString &) {}
    QString nativeKey() const { return QString(); }

    bool create(qsizetype size, AccessMode mode = ReadWrite) { Q_UNUSED(size); Q_UNUSED(mode); return false; }
    qsizetype size() const { return 0; }

    bool attach(AccessMode mode = ReadWrite) { Q_UNUSED(mode); return false; }
    bool isAttached() const { return false; }
    bool detach() { return false; }

    bool lock() { return false; }
    bool unlock() { return true; }

    void *data() { return nullptr; }
    const void* constData() const { return nullptr; }
    const void *data() const { return nullptr; }

    SharedMemoryError error() const { return SharedMemoryError(); }
    QString errorString() const { return QString(); }
};
#endif // QT_CONFIG(sharedmemory) //////////////////////////////////////////////



/* ************************************************************************** */
#endif // SINGLEAPPLICATION_P_H
