// UtilsString.js
// Version 11
.pragma library

/* ************************************************************************** */

/*!
 * _padNumber()
 * Only used for padding durations whithin this file.
 */
function _padNumber(n, width) {
    width = width || 2;

    n = n + '';
    return (n.length >= width) ? n : new Array(width - n.length + 1).join('0') + n;
}

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
    var milliseconds = Math.round(duration - (hours * 3600000) - (minutes * 60000)) - (seconds * 1000);

    if (hours > 0) {
        text += hours.toString();

        if (hours > 1)
            text += " " + qsTr("hours") + " ";
        else
            text += " " + qsTr("hour") + " ";
    }
    if (minutes > 0) {
        text += minutes.toString() + " " + qsTr("min") + " ";
    }
    if (seconds > 0) {
        text += seconds.toString() + " " + qsTr("sec") + " ";
    }
    if (milliseconds > 0) {
        text += milliseconds.toString() + " " + qsTr("ms");
    }

    return text;
}

/*!
 * durationToString_short()
 * Format is 'XX h XX m XX s XX ms'
 */
function durationToString_short(duration) {
    var text = "";

    if (duration < 0) return qsTr("?");
    if (duration === 0) return qsTr("0 s");

    var hours = Math.floor(duration / 3600000);
    var minutes = Math.floor((duration - (hours * 3600000)) / 60000);
    var seconds = Math.floor((duration - (hours * 3600000) - (minutes * 60000)) / 1000);
    var milliseconds = Math.round(duration - (hours * 3600000) - (minutes * 60000)) - (seconds * 1000);

    if (hours > 0) {
        text += hours.toString() + " " + qsTr("m") + " ";
    }
    if (minutes > 0) {
        text += minutes.toString() + " " + qsTr("m") + " ";
    }
    if (seconds > 0) {
        text += seconds.toString() + " " + qsTr("s") + " ";
    }
    if (milliseconds > 0) {
        text += milliseconds.toString() + " " + qsTr("ms");
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
    var milliseconds = Math.round(duration - (hours * 3600000) - (minutes * 60000)) - (seconds * 1000);

    if (hours > 0) {
        text += hours.toString() + qsTr("h") + " ";
    }
    if (minutes > 0) {
        text += minutes.toString() + qsTr("m") + " ";
    }

    if (seconds <= 1 && milliseconds > 0) {
        text += seconds.toString() + qsTr("s") + " " + milliseconds.toString() + qsTr("ms");
    } else {
        text += Math.round((duration - (hours * 3600000) - (minutes * 60000)) / 1000).toString() + qsTr("s");
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
    var milliseconds = Math.round(duration - (hours * 3600000) - (minutes * 60000)) - (seconds * 1000);

    if (hours > 0) {
        text += hours.toString() + qsTr("h") + " ";
    }
    if (minutes > 0) {
        text += minutes.toString() + qsTr("m") + " ";
    }

    if (seconds < 60 && milliseconds > 0) {
        text += seconds.toString() + qsTr("s") + " " + milliseconds.toString() + qsTr("ms");
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

        if (hours > 0) text += _padNumber(hours).toString() + ":";
        text += _padNumber(minutes).toString() + ":";
        text += _padNumber(seconds).toString();
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

        if (hours > 0) text += _padNumber(hours).toString() + ":";
        text += _padNumber(minutes).toString() + ":";
        text += _padNumber(seconds).toString();
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

        text += _padNumber(hours).toString() + ":";
        text += _padNumber(minutes).toString() + ":";
        text += _padNumber(seconds).toString();
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
        var milliseconds = Math.round((duration_ms - (hours * 3600000) - (minutes * 60000)) - (seconds * 1000));

        if (hours > 0) {
            text += _padNumber(hours).toString();
            text += ":";
        }

        if (minutes > 0) {
            text += _padNumber(minutes).toString();
            text += ":";
        }

        if (seconds > 0)
            text += _padNumber(seconds).toString();
        if (seconds === 0)
            text += "00";
        if (milliseconds > 0)
            text += "." + _padNumber(milliseconds, 3).toString();
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
        var milliseconds = Math.round((duration_ms - (hours * 3600000) - (minutes * 60000)) - (seconds * 1000));

        if (hours > 0)
            text += _padNumber(hours).toString();
        if (hours === 0)
            text += "00";

        text += ":";

        if (minutes > 0)
            text += _padNumber(minutes).toString();
        if (minutes === 0)
            text += "00";

        text += ":";

        if (seconds > 0)
            text += _padNumber(seconds).toString();
        if (seconds === 0)
            text += "00";
        if (milliseconds > 0)
            text += "." + milliseconds.toString();
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
    var text = "";
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
    }

    return text;
}

/*!
 * bytesToString_short()
 * unit: 0 is KB, 1 is KiB
 */
function bytesToString_short(bytes, unit) {
    var text = "";
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
    }

    return text;
}

/* ************************************************************************** */

/*!
 * altitudeToString()
 */
function altitudeToString(value, precision, unit) {
    var text = '';
    unit = unit || 0;

    if (unit === 0) {
        text = value.toFixed(precision) + " " + qsTr("m");
    } else {
        text = (value / 0.3048).toFixed(precision) + " " + qsTr("ft");
    }

    return text;
}

/*!
 * altitudeUnit()
 */
function altitudeUnit(unit) {
    var text = '';
    unit = unit || 0;

    if (unit === 0) {
        text = qsTr("meter");
    } else {
        text = qsTr("feet");
    }

    return text;
}

/*!
 * distanceToString()
 */
function distanceToString(value_m, precision, unit) {
    var text = "";
    unit = unit || 0;

    if (unit === 0) {
        if (value_m > 1000) {
            text = (value_m / 1000).toFixed(precision) + " " + qsTr("km");
        } else {
            text = (value_m).toFixed(precision) + " " + qsTr("m");
        }
    } else {
        if (value_m > 1609.3) {
            text = (value_m / 1609.344).toFixed(precision) + " " + qsTr("mi");
        } else {
            text = (value_m / 0.9144).toFixed(precision) + " " + qsTr("yd");
        }
    }

    return text;
}

/*!
 * distanceToString_km()
 */
function distanceToString_km(value_km, precision, unit) {
    var text = "";
    unit = unit || 0;

    if (unit === 0) {
        text = value_km.toFixed(precision) + " " + qsTr("km");
    } else {
        text = (value_km / 1609.344).toFixed(precision) + " " + qsTr("mi");
    }

    return text;
}

/*!
 * speedToString()
 */
function speedToString(value, precision, unit) {
    return distanceToString(value, precision, unit) + qsTr("/h");
}

function speedToString_km(value, precision, unit) {
    return distanceToString_km(value, precision, unit) + qsTr("/h");
}

/*!
 * speedUnit()
 */
function speedUnit(unit) {
    var text = "";
    unit = unit || 0;

    if (unit === 0) {
        text = qsTr("km/h");
    } else {
        text = qsTr("mi/h");
    }

    return text;
}

/* ************************************************************************** */
