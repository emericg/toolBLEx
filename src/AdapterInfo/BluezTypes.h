/*!
 * This file is part of toolBLEx.
 * Copyright (c) 2026 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef BLUEZ_TYPES_H
#define BLUEZ_TYPES_H
/* ************************************************************************** */

#include <QMap>
#include <QString>
#include <QVariantMap>
#include <QDBusObjectPath>
#include <QDBusMetaType>

/* ************************************************************************** */

//! Interfaces of a D-Bus object, with their properties: DICT<STRING, DICT<STRING, VARIANT>>
typedef QMap <QString, QVariantMap> InterfaceList;

//! D-Bus objects, with their interfaces: DICT<OBJPATH, DICT<STRING, DICT<STRING, VARIANT>>>
typedef QMap <QDBusObjectPath, InterfaceList> ManagedObjectList;

/*!
 * \brief Register the BlueZ D-Bus types, needed by QDBusPendingReply.
 *
 * Can be called more than once.
 */
inline void registerBluezTypes()
{
    qDBusRegisterMetaType<InterfaceList>();
    qDBusRegisterMetaType<ManagedObjectList>();
}

/* ************************************************************************** */
#endif // BLUEZ_TYPES_H
