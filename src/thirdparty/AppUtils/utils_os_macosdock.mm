/*!
 * Copyright (c) 2019 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "utils_os_macosdock.h"

#if defined(Q_OS_MACOS)

#include <QQuickWindow>
#include <objc/runtime.h>
#include <AppKit/AppKit.h>

#import <Foundation/Foundation.h>

static MacOSDockHandler *instance = nullptr;

/* ************************************************************************** */

bool dockClickHandler(id self, SEL _cmd, ...)
{
    Q_UNUSED(self)
    Q_UNUSED(_cmd)

    if (instance)
    {
        Q_EMIT instance->dockIconClicked();
    }

    // Return NO (false) to suppress the default macOS actions
    return false;
}

/* ************************************************************************** */

MacOSDockHandler *MacOSDockHandler::getInstance()
{
    if (instance == nullptr)
    {
        instance = new MacOSDockHandler();
    }

    return instance;
}

MacOSDockHandler::MacOSDockHandler() : QObject()
{
    // Setup dock click handler
    Class delClass = (Class)[[[NSApplication sharedApplication] delegate] class];
    SEL shouldHandle = sel_registerName("applicationShouldHandleReopen:hasVisibleWindows:");
    class_replaceMethod(delClass, shouldHandle, reinterpret_cast<IMP>(dockClickHandler), "B@:");
}

MacOSDockHandler::~MacOSDockHandler()
{
    delete instance;
}

/* ************************************************************************** */

void MacOSDockHandler::setupDock(QQuickWindow *window)
{
    if (!window)
    {
        qWarning() << "MacOSDockHandler::setupDock() no QQuickWindow passed";
        return;
    }

    m_saved_window = window;

    QObject::connect(this, &MacOSDockHandler::dockIconClicked, m_saved_window, &QQuickWindow::show);
    QObject::connect(this, &MacOSDockHandler::dockIconClicked, m_saved_window, &QQuickWindow::raise);
}

void MacOSDockHandler::toggleDockIconVisibility(bool show)
{
    ProcessSerialNumber psn = {0, kCurrentProcess};

    if (show)
    {
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    }
    else
    {
        TransformProcessType(&psn, kProcessTransformToUIElementApplication);
    }
}

/* ************************************************************************** */
#endif // Q_OS_MACOS
