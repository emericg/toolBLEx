/*!
 * Copyright (c) 2024 Emeric Grange
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

#include "utils_clipboard.h"

#include <QGuiApplication>
#include <QClipboard>
#include <QMimeData>

/* ************************************************************************** */

void UtilsClipboard::clear()
{
    //
}

void UtilsClipboard::setText(const QString &txt)
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    QString originalText = clipboard->text();

    clipboard->setText(txt);
}

QString UtilsClipboard::getText()
{
    const QClipboard *clipboard = QGuiApplication::clipboard();
    const QMimeData *mimeData = clipboard->mimeData();

    if (mimeData->hasText())
    {
        return mimeData->text();
        // Qt::PlainText;
    }
    else
    {
        // not handled
    }

    return QString();
}

/* ************************************************************************** */
