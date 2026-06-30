// UtilsString.js
.pragma library

/* ************************************************************************** */

/*!
 * Pad a number
 * \param n: number to pad
 * \param width: width after padding (default 2)
 * \param z: character to insert (default '0')
 *
 * example: padNumber(2, 3, 'x') => xx2
 */
function padNumber(n, width = 2, z = '0') {
    return String(n).padStart(width, z);
}

/* ************************************************************************** */

/*!
 * Capitalize the first character of a string.
 *
 * example: capitalizeFirst("utils utils utils") => "Utils utils utils"
 */
function capitalizeFirst(str) {
    if (!str) return '';

    str = str.toString();
    return str.charAt(0).toUpperCase() + str.slice(1);
}

/* ************************************************************************** */

/*!
 * durationToString_long()
 * Format is 'XX hours XX min XX sec XX ms'
 */
function durationToString_long(duration) {
    var text = "";

    if (duration < 0) return qsTr("Unknown duration");

    var hours = Math.floor(duration / 3600000);
    var minutes = Math.floor((duration - (hours * 3600000)) / 60000);
    var seconds = Math.floor((duration - (hours * 3600000) - (minutes * 60000)) / 1000);
    var milliseconds = Math.floor(duration - (hours * 3600000) - (minutes * 60000) - (seconds * 1000));

    if (hours > 0) {
        text += hours.toString();

        if (hours > 1)
            text += " " + qsTr("hours") + " ";
        else
            text += " " + qsTr("hour") + " ";
    }
    if (minutes > 0) {
        text += minutes.toString() + " " + qsTr("min", "short for minutes") + " ";
    }
    if (seconds > 0) {
        text += seconds.toString() + " " + qsTr("sec", "short for seconds") + " ";
    }
    if (milliseconds > 0) {
        text += milliseconds.toString() + " " + qsTr("ms", "short for milliseconds");
    }

    return text;
}

/*!
 * durationToString_short()
 * Format is 'XX h XX m XX s XX ms'
 */
function durationToString_short(duration) {
    var text = "";

    if (duration < 0) return "?";
    if (duration === 0) return qsTr("0 s");

    var hours = Math.floor(duration / 3600000);
    var minutes = Math.floor((duration - (hours * 3600000)) / 60000);
    var seconds = Math.floor((duration - (hours * 3600000) - (minutes * 60000)) / 1000);
    var milliseconds = Math.floor(duration - (hours * 3600000) - (minutes * 60000) - (seconds * 1000));

    if (hours > 0) {
        text += hours.toString() + " " + qsTr("h", "short for hours") + " ";
    }
    if (minutes > 0) {
        text += minutes.toString() + " " + qsTr("m", "short for minutes") + " ";
    }
    if (seconds > 0) {
        text += seconds.toString() + " " + qsTr("s", "short for seconds") + " ";
    }
    if (milliseconds > 0) {
        text += milliseconds.toString() + " " + qsTr("ms", "short for milliseconds");
    }

    return text;
}

/*!
 * durationToString_compact()
 * Format is 'XXh XXm XXs [XXms]'
 *
 * Last second is rounded and milliseconds are hidden unless duration is less than two seconds.
 */
function durationToString_compact(duration) {
    var text = "";

    if (duration < 0) return qsTr("unknown");
    if (duration === 0) return qsTr("0s");

    var hours = Math.floor(duration / 3600000);
    var minutes = Math.floor((duration - (hours * 3600000)) / 60000);
    var seconds = Math.floor((duration - (hours * 3600000) - (minutes * 60000)) / 1000);
    var milliseconds = Math.floor(duration - (hours * 3600000) - (minutes * 60000) - (seconds * 1000));

    if (hours > 0) {
        text += hours.toString() + qsTr("h", "short for hours") + " ";
    }
    if (minutes > 0) {
        text += minutes.toString() + qsTr("m", "short for minutes") + " ";
    }

    if (seconds <= 1 && milliseconds > 0) {
        text += seconds.toString() + qsTr("s", "short for seconds") + " " +
                milliseconds.toString() + qsTr("ms", "short for milliseconds");
    } else {
        text += Math.round((duration - (hours * 3600000) - (minutes * 60000)) / 1000).toString() + qsTr("s", "short for seconds");
    }

    return text;
}

/*!
 * durationToString_supercompact()
 * Format is 'XXh XXm [XXs XXms]'
 *
 * Seconds and milliseconds are hidden unless duration is less than a minute.
 */
function durationToString_supercompact(duration) {
    var text = "";

    if (duration < 0) return qsTr("unknown");
    if (duration === 0) return qsTr("0s");

    var hours = Math.floor(duration / 3600000);
    var minutes = Math.floor((duration - (hours * 3600000)) / 60000);
    var seconds = Math.floor((duration - (hours * 3600000) - (minutes * 60000)) / 1000);
    var milliseconds = Math.floor(duration - (hours * 3600000) - (minutes * 60000) - (seconds * 1000));

    if (hours > 0) {
        text += hours.toString() + qsTr("h", "short for hours") + " ";
    }
    if (minutes > 0) {
        text += minutes.toString() + qsTr("m", "short for minutes") + " ";
    }

    if (hours === 0 && minutes === 0) {
        text += seconds.toString() + qsTr("s", "short for seconds");
        if (milliseconds > 0) {
            text += " " + milliseconds.toString() + qsTr("ms", "short for milliseconds");
        }
    }

    return text;
}

/* ************************************************************************** */

/*!
 * durationToString_ISO8601_compact()
 * Format is 'mm:ss' (strict)
 *
 * Note: great for displaying media current position in player
 * Ref: https://en.wikipedia.org/wiki/ISO_8601#Times
 */
function durationToString_ISO8601_compact(duration) {
    var text = "";

    if (duration > 1000) {
        var hours = Math.floor(duration / 3600000);
        var minutes = Math.floor((duration - (hours * 3600000)) / 60000);
        var seconds = Math.round((duration - (hours * 3600000) - (minutes * 60000)) / 1000);

        if (hours > 0) text += padNumber(hours) + ":";
        text += padNumber(minutes) + ":";
        text += padNumber(seconds);
    } else {
        text = "00:00";
    }

    return text
}

/*!
 * durationToString_ISO8601_compact_loose()
 * Format is 'mm:ss' (loose)
 *
 * Note: great for displaying media duration in thumbnail
 * Ref: https://en.wikipedia.org/wiki/ISO_8601#Times
 */
function durationToString_ISO8601_compact_loose(duration) {
    var text = "";

    if (duration > 1000) {
        var hours = Math.floor(duration / 3600000);
        var minutes = Math.floor((duration - (hours * 3600000)) / 60000);
        var seconds = Math.round((duration - (hours * 3600000) - (minutes * 60000)) / 1000);

        if (hours > 0) text += padNumber(hours) + ":";
        text += padNumber(minutes) + ":";
        text += padNumber(seconds);
    } else if (duration > 0) {
        text = "~00:01";
    } else {
        text = "?";
    }

    return text
}

/*!
 * durationToString_ISO8601_regular()
 * Format is 'hh:mm:ss' (strict)
 *
 * Ref: https://en.wikipedia.org/wiki/ISO_8601#Times
 */
function durationToString_ISO8601_regular(duration_ms) {
    var text = "";

    if (duration_ms > 1000) {
        var hours = Math.floor(duration_ms / 3600000);
        var minutes = Math.floor((duration_ms - (hours * 3600000)) / 60000);
        var seconds = Math.round((duration_ms - (hours * 3600000) - (minutes * 60000)) / 1000);

        text += padNumber(hours) + ":";
        text += padNumber(minutes) + ":";
        text += padNumber(seconds);
    } else if (duration_ms > 0) {
        text = "00:00:01";
    } else {
        text = "00:00:00";
    }

    return text
}

/*!
 * durationToString_ISO8601_full_loose()
 * Format is 'hh:mm:ss.sss' (loose)
 *
 * Ref: https://en.wikipedia.org/wiki/ISO_8601#Times
 */
function durationToString_ISO8601_full_loose(duration_ms) {
    var text = "";

    if (duration_ms > 0) {
        var hours = Math.floor(duration_ms / 3600000);
        var minutes = Math.floor((duration_ms - (hours * 3600000)) / 60000);
        var seconds = Math.floor((duration_ms - (hours * 3600000) - (minutes * 60000)) / 1000);
        var milliseconds = Math.floor((duration_ms - (hours * 3600000) - (minutes * 60000)) - (seconds * 1000));

        if (hours > 0) {
            text += padNumber(hours);
            text += ":";
        }

        if (minutes > 0) {
            text += padNumber(minutes);
            text += ":";
        }

        if (seconds > 0)
            text += padNumber(seconds);
        if (seconds === 0)
            text += "00";
        if (milliseconds > 0)
            text += "." + padNumber(milliseconds, 3);
    } else {
        text = "00:00";
    }

    return text
}

/*!
 * durationToString_ISO8601_full()
 * Format is 'hh:mm:ss.sss' (strict)
 *
 * Note: format used by ffmpeg CLI
 * Ref: https://en.wikipedia.org/wiki/ISO_8601#Times
 */
function durationToString_ISO8601_full(duration_ms) {
    var text = "";

    if (duration_ms > 0) {
        var hours = Math.floor(duration_ms / 3600000);
        var minutes = Math.floor((duration_ms - (hours * 3600000)) / 60000);
        var seconds = Math.floor((duration_ms - (hours * 3600000) - (minutes * 60000)) / 1000);
        var milliseconds = Math.floor((duration_ms - (hours * 3600000) - (minutes * 60000)) - (seconds * 1000));

        if (hours > 0)
            text += padNumber(hours);
        if (hours === 0)
            text += "00";

        text += ":";

        if (minutes > 0)
            text += padNumber(minutes);
        if (minutes === 0)
            text += "00";

        text += ":";

        if (seconds > 0)
            text += padNumber(seconds);
        if (seconds === 0)
            text += "00";
        if (milliseconds > 0)
            text += "." + padNumber(milliseconds, 3);
    } else {
        text = "00:00:00";
    }

    return text
}

/* ************************************************************************** */

/*!
 * bytesToString()
 * unit: 0 is KB, 1 is KiB
 */
function bytesToString(bytes, unit) {
    var text = '0';
    unit = unit || 0;

    var base = (unit === 1) ? 1024 : 1000
    //if (bytes > 1024*1024*1024*1024) return 'NaN';

    if (bytes > 0) {
        if ((bytes/(base*base*base)) >= 1000.0)
            text = (bytes/(base*base*base*base)).toFixed(1) + " " + ((unit === 1) ? "TiB" : "TB");
        else if ((bytes/(base*base*base)) >= 128.0)
            text = (bytes/(base*base*base)).toFixed(0) + " " + ((unit === 1) ? "GiB" : "GB");
        else if ((bytes/(base*base*base)) >= 1.0)
            text = (bytes/(base*base*base)).toFixed(1) + " " + ((unit === 1) ? "GiB" : "GB");
        else if ((bytes/(base*base)) >= 1.0)
            text = (bytes/(base*base)).toFixed(1) + " " + ((unit === 1) ? "MiB" : "MB");
        else if ((bytes/base) >= 1.0)
            text = (bytes/base).toFixed(1) + " " + ((unit === 1) ? "KiB" : "KB");
        else
            text = bytes.toFixed(0) + " B";
    }

    return text;
}

/*!
 * bytesToString_short()
 * unit: 0 is KB, 1 is KiB
 */
function bytesToString_short(bytes, unit) {
    var text = '0';
    unit = unit || 0;

    var base = (unit === 1) ? 1024 : 1000
    //if (bytes > 1024*1024*1024*1024) return 'NaN';

    if (bytes > 0) {
        if ((bytes/(base*base*base)) >= 1000.0)
            text = (bytes/(base*base*base*base)).toFixed(1) + " " + ((unit === 1) ? "TiB" : "TB");
        else if ((bytes/(base*base*base)) >= 128.0)
            text = (bytes/(base*base*base)).toFixed(0) + " " + ((unit === 1) ? "GiB" : "GB");
        else if ((bytes/(base*base*base)) >= 1.0)
            text = (bytes/(base*base*base)).toFixed(1) + " " + ((unit === 1) ? "GiB" : "GB");
        else if ((bytes/(base*base)) >= 1.0)
            text = (bytes/(base*base)).toFixed(1) + " " + ((unit === 1) ? "MiB" : "MB");
        else if ((bytes/base) >= 1.0)
            text = (bytes/base).toFixed(1) + " " + ((unit === 1) ? "KiB" : "KB");
        else
            text = bytes.toFixed(0) + " B";
    }

    return text;
}

/* ************************************************************************** */

/*!
 * altitudeToString()
 * unit: 0 is metric, 1 is imperial
 */
function altitudeToString(value, precision, unit) {
    var text = '';
    unit = unit || 0;

    if (unit === 0) {
        text = value.toFixed(precision) + " " + qsTr("m", "short for meters");
    } else {
        text = (value / 0.3048).toFixed(precision) + " " + qsTr("ft", "short for feet");
    }

    return text;
}

/*!
 * Return the altitude unit name, for use in legends and stuff
 * unit: 0 is metric, 1 is imperial
 */
function altitudeUnit(unit) {
    var text = "";
    unit = unit || 0;

    if (unit === 0) {
        text = qsTr("meter", "altitude unit")
    } else {
        text = qsTr("foot", "altitude unit")
    }

    return text;
}

/*!
 * distanceToString()
 * unit: 0 is metric, 1 is imperial
 */
function distanceToString(value_m, precision, unit) {
    var text = "";
    unit = unit || 0;

    if (unit === 0) {
        if (value_m > 1000) {
            text = (value_m / 1000).toFixed(precision) + " " + qsTr("km", "short for kilometers");
        } else {
            text = (value_m).toFixed(precision) + " " + qsTr("m", "short for meters");
        }
    } else {
        if (value_m > 1609.3) {
            text = (value_m / 1609.344).toFixed(precision) + " " + qsTr("mi", "short for miles");
        } else {
            text = (value_m / 0.9144).toFixed(precision) + " " + qsTr("yd", "short for yards");
        }
    }

    return text;
}

/*!
 * distanceToString_km()
 * unit: 0 is metric, 1 is imperial
 */
function distanceToString_km(value_km, precision, unit) {
    var text = "";
    unit = unit || 0;

    if (unit === 0) {
        text = value_km.toFixed(precision) + " " + qsTr("km", "short for kilometers");
    } else {
        text = (value_km / 1.609344).toFixed(precision) + " " + qsTr("mi", "short for miles");
    }

    return text;
}

/*!
 * speedToString()
 * unit: 0 is metric, 1 is imperial
 */
function speedToString(value_m, precision, unit) {
    var text = "";
    unit = unit || 0;

    if (unit === 0) {
        text = (value_m / 1000).toFixed(precision) + " " + qsTr("km/h", "kilometers per hour");
    } else {
        text = (value_m / 1609.344).toFixed(precision) + " " + qsTr("mi/h", "miles per hour");
    }

    return text;
}

function speedToString_km(value, precision, unit) {
    return distanceToString_km(value, precision, unit) + qsTr("/h", "short for per hour");
}

/*!
 * Return the speed unit name, for use in legends and stuff
 * unit: 0 is km/h, 1 is mi/h
 */
function speedUnit(unit) {
    var text = "";
    unit = unit || 0;

    if (unit === 0) {
        text = qsTr("km/h", "kilometers per hour");
    } else {
        text = qsTr("mi/h", "miles per hour");
    }

    return text;
}

/* ************************************************************************** */

/*!
 * weightToString()
 * unit: 0 is kg, 1 is lb
 */
function weightToString(value_kg, precision, unit) {
    var text = "";
    unit = unit || 0;

    if (unit === 0) {
        text = value_kg.toFixed(precision) + " " + qsTr("kg", "short for kilograms");
    } else {
        text = (value_kg * 2.20462262185).toFixed(precision) + " " + qsTr("lb", "short for pounds");
    }

    return text;
}

/* ************************************************************************** */

/*!
 * temperatureToString()
 * unit: 0 is °C, 1 is °F
 */
function temperatureToString(value_c, precision, unit) {
    var text = "";
    unit = unit || 0;

    if (unit === 0) {
        text = value_c.toFixed(precision) + " " + qsTr("°C", "degrees Celsius");
    } else {
        text = (value_c * 1.8 + 32).toFixed(precision) + " " + qsTr("°F", "degrees Fahrenheit");
    }

    return text;
}

/* ************************************************************************** */
