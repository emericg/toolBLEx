/*!
 * This file is part of toolBLEx.
 * Copyright (c) 2022 Emeric Grange - All Rights Reserved
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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_UTILS_H
#define DEVICE_UTILS_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QQmlContext>
#include <QQmlApplicationEngine>

/* ************************************************************************** */

class DeviceUtils: public QObject
{
    Q_OBJECT

public:
    static void registerQML()
    {
        qRegisterMetaType<DeviceUtils::DeviceType>("DeviceUtils::DeviceType");
        qRegisterMetaType<DeviceUtils::DeviceCapabilities>("DeviceUtils::DeviceCapabilities");
        qRegisterMetaType<DeviceUtils::DeviceSensors>("DeviceUtils::DeviceSensors");
        qRegisterMetaType<DeviceUtils::DeviceStatus>("DeviceUtils::DeviceStatus");
        qRegisterMetaType<DeviceUtils::DeviceActions>("DeviceUtils::DeviceActions");
        qRegisterMetaType<DeviceUtils::BluetoothMode>("DeviceUtils::BluetoothMode");
        qRegisterMetaType<DeviceUtils::BluetoothAdvertisementMode>("DeviceUtils::BluetoothAdvertisementMode");

        qmlRegisterType<DeviceUtils>("DeviceUtils", 1, 0, "DeviceUtils");
    }

    enum BluetoothMode {
        DEVICE_BLE_UNKNOWN          = 0,

        DEVICE_BLE_CONNECTION       = (1 <<  0), //!< Can get/set data by connecting to the device
        DEVICE_BLE_ADVERTISEMENT    = (1 <<  1), //!< Can get data from advertisement packet
    };
    Q_ENUM(BluetoothMode)

    enum BluetoothAdvertisementMode {
        BLE_ADV_SERVICEDATA         = 0,
        BLE_ADV_MANUFACTURERDATA    = 1
    };
    Q_ENUM(BluetoothAdvertisementMode)

    enum DeviceType {
        DEVICE_UNKNOWN              = 0,

        DEVICE_PLANTSENSOR          = 1,
        DEVICE_THERMOMETER,
        DEVICE_ENVIRONMENTAL,

        DEVICE_LIGHT                 = 8,
        DEVICE_BEACON,
        DEVICE_REMOTE,
        DEVICE_PGP,
    };
    Q_ENUM(DeviceType)

    enum DeviceCapabilities {
        DEVICE_REALTIME             = (1 <<  0), //!< Can report realtime data
        DEVICE_HISTORY              = (1 <<  1), //!< Can report sensor history
        DEVICE_BATTERY              = (1 <<  2), //!< Can report its battery level
        DEVICE_CLOCK                = (1 <<  3), //!< Has an onboard clock
        DEVICE_LED_STATUS           = (1 <<  4), //!< Has a status LED
        DEVICE_LED_RGB              = (1 <<  5), //!< Has an addressable LED
        DEVICE_BUTTONS              = (1 <<  6), //!< Has button(s)
        DEVICE_LAST_MOVE            = (1 <<  7), //!< Can report the last time it has been physically moved
        DEVICE_WATER_TANK           = (1 <<  8), //!< Has a water tank and automatic/manual watering capability
        DEVICE_CALIBRATION          = (1 <<  9), //!< Can be calibrated
        DEVICE_REBOOT               = (1 << 10), //!< Can be rebooted
    };
    Q_ENUM(DeviceCapabilities)

    enum DeviceSensors {
        // plant data
        SENSOR_SOIL_MOISTURE        = (1 <<  0), //!< Has a soil moisture sensor
        SENSOR_SOIL_CONDUCTIVITY    = (1 <<  1), //!< Has a soil electrical conductivity / fertility sensor
        SENSOR_SOIL_TEMPERATURE     = (1 <<  2), //!< Has a soil temperature sensor
        SENSOR_SOIL_PH              = (1 <<  3), //!< Has a soil PH sensor
        // hygrometer data
        SENSOR_TEMPERATURE          = (1 <<  6), //!< Has a temperature sensor
        SENSOR_HUMIDITY             = (1 <<  7), //!< Has an humidity sensor
        // environmental data (weather station)
        SENSOR_PRESSURE             = (1 <<  8), //!< Has a barometer (pressure sensor)
        SENSOR_LUMINOSITY           = (1 <<  9), //!< Has a light sensor
        SENSOR_UV                   = (1 << 10), //!< Has an UV light sensor
        SENSOR_SOUND                = (1 << 11), //!< Has a sound level sensor
        SENSOR_WATER_LEVEL          = (1 << 12), //!< Has a rain gauge (or water tank level)
        SENSOR_WIND_DIRECTION       = (1 << 13), //!< Has a weather vane
        SENSOR_WIND_SPEED           = (1 << 14), //!< Has an anemometer
        // environmental data (air quality monitoring)
        SENSOR_PM1                  = (1 << 16),
        SENSOR_PM25                 = (1 << 17),
        SENSOR_PM10                 = (1 << 18),
        SENSOR_O2                   = (1 << 19),
        SENSOR_O3                   = (1 << 20),
        SENSOR_CO                   = (1 << 21),
        SENSOR_CO2                  = (1 << 22),
        SENSOR_eCO2                 = (1 << 23),
        SENSOR_NO2                  = (1 << 24),
        SENSOR_SO2                  = (1 << 25),
        SENSOR_VOC                  = (1 << 26),
        SENSOR_HCHO                 = (1 << 27),
        // environmental data (geiger counter)
        SENSOR_GEIGER               = (1 << 31),
    };
    Q_ENUM(DeviceSensors)

    enum DeviceStatus {
        DEVICE_OFFLINE              =  0, //!< Not connected

        DEVICE_QUEUED               =  1, //!< In the update queue, not started
        DEVICE_CONNECTING           =  2, //!< Trying to connect to the device
        DEVICE_CONNECTED            =  3, //!< Connected

        DEVICE_WORKING              =  8, //!< Connected, doing something
        DEVICE_UPDATING             =  9, //!< Connected, reading latest data
        DEVICE_UPDATING_REALTIME    = 10, //!< Connected, reading realtime data
        DEVICE_UPDATING_HISTORY     = 11, //!< Connected, reading data history
    };
    Q_ENUM(DeviceStatus)

    enum DeviceActions {
        ACTION_IDLE                 = 0,  //!< No action, stay connected

        ACTION_UPDATE,                    //!< Read sensor latest data
        ACTION_UPDATE_REALTIME,           //!< Stay connected and read sensor data
        ACTION_UPDATE_HISTORY,            //!< Sync sensor history

        ACTION_LED_BLINK = 8,
        ACTION_CLEAR_HISTORY,
        ACTION_WATERING,
        ACTION_CALIBRATE,

        ACTION_SCAN = 64,                 //!< Scan for services and their characteristics
        ACTION_SCAN_WITH_VALUES,          //!< Scan for services and their characteristics (and associated values)
        ACTION_SCAN_WITHOUT_VALUES,       //!< Scan for services and their characteristics (without associated values)

        ACTION_REBOOT = 256,
        ACTION_SHUTDOWN,
    };
    Q_ENUM(DeviceActions)
};

/* ************************************************************************** */

class ChartDataHistory: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool today READ isToday CONSTANT)
    Q_PROPERTY(int day READ getDay CONSTANT)
    Q_PROPERTY(int hour READ getHour CONSTANT)
    Q_PROPERTY(QDateTime datetime READ getDateTime CONSTANT)

    Q_PROPERTY(float soilMoisture READ getSoilMoisture CONSTANT)
    Q_PROPERTY(float soilConductivity READ getSoilCondu CONSTANT)
    Q_PROPERTY(float soilTemperature READ getSoilTemperature CONSTANT)
    Q_PROPERTY(float soilPH READ getSoilPH CONSTANT)
    Q_PROPERTY(float temperature READ getTemperature CONSTANT)
    Q_PROPERTY(float humidity READ getHumidity CONSTANT)
    Q_PROPERTY(float luminosityLux READ getLuminosityLux CONSTANT)
    Q_PROPERTY(float luminosityMmol READ getLuminosityMmol CONSTANT)

    Q_PROPERTY(float temperatureMax READ getTemperatureMax CONSTANT)
    Q_PROPERTY(float luminosityLuxMax READ getLuminosityLuxMax CONSTANT)

    QDateTime datetime;

    float soilMoisture = -99.f;
    float soilConductivity = -99.f;
    float soilTemperature = -99.f;
    float soilPH = -99.f;
    float temperature = -99.f;
    float humidity = -99.f;
    float luminosityLux = -99.f;
    float luminosityMmol = -99.f;

    float temperatureMax = -99.f;
    float luminosityLuxMax = -99.f;

public:
    ChartDataHistory(const QDateTime &dt,
                     float sm, float sc, float st,
                     float t, float h, float l,
                     QObject *parent) : QObject(parent)
    {
        datetime = dt;

        soilMoisture = sm;
        soilConductivity = sc;
        soilTemperature = st;
        temperature = t;
        humidity = h;
        luminosityLux = l;
    }

    ChartDataHistory(const QDateTime &dt,
                     float sm, float sc, float st,
                     float t, float h, float l,
                     float tm, float lm,
                     QObject *parent) : QObject(parent)
    {
        datetime = dt;

        soilMoisture = sm;
        soilConductivity = sc;
        soilTemperature = st;
        temperature = t;
        humidity = h;
        luminosityLux = l;

        temperatureMax = tm;
        luminosityLuxMax = lm;
    }

public slots:
    bool isToday() { return (datetime.date() == QDate::currentDate()); }
    int getDay() { return datetime.date().day(); }
    int getHour() { return datetime.time().hour(); }
    QDateTime getDateTime() { return datetime; }

    float getSoilMoisture() { return soilMoisture; }
    float getSoilCondu() { return soilConductivity; }
    float getSoilTemperature() { return soilTemperature; }
    float getSoilPH() { return soilPH; }
    float getTemperature() { return temperature; }
    float getHumidity() { return humidity; }
    float getLuminosityLux() { return luminosityLux; }
    float getLuminosityMmol() { return luminosityMmol; }

    float getTemperatureMax() { return temperatureMax; }
    float getLuminosityLuxMax() { return luminosityLuxMax; }
};

/* ************************************************************************** */

class ChartDataMinMax: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool today READ isToday CONSTANT)
    Q_PROPERTY(int day READ getDay CONSTANT)
    Q_PROPERTY(int hour READ getHour CONSTANT)
    Q_PROPERTY(QDateTime datetime READ getDateTime CONSTANT)

    Q_PROPERTY(float tempMin READ getTempMin CONSTANT)
    Q_PROPERTY(float tempMean READ getTempMean CONSTANT)
    Q_PROPERTY(float tempMax READ getTempMax CONSTANT)
    Q_PROPERTY(int hygroMin READ getHygroMin CONSTANT)
    Q_PROPERTY(int hygroMax READ getHygroMax CONSTANT)

    QDateTime datetime;

    float tempMin;
    float tempMean = -99.f;
    float tempMax;
    int hygroMin;
    int hygroMax;

public:
    ChartDataMinMax(const QDateTime &dt,
                    float tmin, float t, float tmax,
                    int hmin, int hmax,
                    QObject *parent) : QObject(parent)
    {
        datetime = dt;

        tempMin = tmin; tempMean = t; tempMax = tmax;
        hygroMin = hmin; hygroMax = hmax;
    }

public slots:
    bool isToday() { return (datetime.date() == QDate::currentDate()); }
    int getDay() { return datetime.date().day(); }
    int getHour() { return datetime.time().hour(); }
    QDateTime getDateTime() { return datetime; }

    float getTempMin() { return tempMin; }
    float getTempMean() { return tempMean; }
    float getTempMax() { return tempMax; }
    int getHygroMin() { return hygroMin; }
    int getHygroMax() { return hygroMax; }
};

/* ************************************************************************** */

class ChartDataVoc: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool today READ isToday CONSTANT)
    Q_PROPERTY(int day READ getDay CONSTANT)
    Q_PROPERTY(int hour READ getHour CONSTANT)
    Q_PROPERTY(QDateTime datetime READ getDateTime CONSTANT)

    Q_PROPERTY(float vocMin READ getVocMin CONSTANT)
    Q_PROPERTY(float vocMean READ getVocMean CONSTANT)
    Q_PROPERTY(float vocMax READ getVocMax CONSTANT)

    Q_PROPERTY(float hchoMin READ getHchoMin CONSTANT)
    Q_PROPERTY(float hchoMean READ getHchoMean CONSTANT)
    Q_PROPERTY(float hchoMax READ getHchoMax CONSTANT)

    Q_PROPERTY(float co2Min READ getCo2Min CONSTANT)
    Q_PROPERTY(float co2Mean READ getCo2Mean CONSTANT)
    Q_PROPERTY(float co2Max READ getCo2Max CONSTANT)

    QDateTime datetime;

    float vocMin;
    float vocMean = -99.f;
    float vocMax;

    float hchoMin;
    float hchoMean = -99.f;
    float hchoMax;

    float co2Min;
    float co2Mean = -99.f;
    float co2Max;

public:
    ChartDataVoc(const QDateTime &dt,
                 float vmin, float v, float vmax,
                 float hmin, float h, float hmax,
                 float cmin, float c, float cmax,
                 QObject *parent) : QObject(parent)
    {
        datetime = dt;

        vocMin = vmin; vocMean = v; vocMax = vmax;
        hchoMin = hmin; hchoMean = h; hchoMax = hmax;
        co2Min = cmin; co2Mean = c; co2Max = cmax;
    }

public slots:
    bool isToday() { return (datetime.date() == QDate::currentDate()); }
    int getDay() { return datetime.date().day(); }
    int getHour() { return datetime.time().hour(); }
    QDateTime getDateTime() { return datetime; }

    float getVocMin() { return vocMin; }
    float getVocMean() { return vocMean; }
    float getVocMax() { return vocMax; }

    float getHchoMin() { return hchoMin; }
    float getHchoMean() { return hchoMean; }
    float getHchoMax() { return hchoMax; }

    float getCo2Min() { return co2Min; }
    float getCo2Mean() { return co2Mean; }
    float getCo2Max() { return co2Max; }
};

/* ************************************************************************** */
#endif // DEVICE_UTILS_H
