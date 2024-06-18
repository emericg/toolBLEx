// UtilsMedia.js
// Version 3
.pragma library

/* ************************************************************************** */

/*!
 * 'display aspect ratio' to string()
 *
 * See: https://en.wikipedia.org/wiki/Display_aspect_ratio
 * Note: we take waaay more margin than with video aspect ratio in order to have
 * more chance to catch aspect ratios from weird definitions...
 */
function darToString(width, height) {
    var ar_string = '';
    var ar_float = 1.0;
    var ar_invert = false;

    if (width >= height) {
        ar_float = width / height;
    } else {
        ar_float = height / width;
        ar_invert = true;
    }

    // desktop displays
    if (ar_float > 1.2 && ar_float < 1.3) { // 1.25
        ar_string = "5:4";
    } else if (ar_float > 1.3 && ar_float < 1.35) { // 1.333
        ar_string = "4:3";
    } else if (ar_float > 1.45 && ar_float < 1.55) { // 1.5
        ar_string = "3:2";
    } else if (ar_float > 1.55 && ar_float < 1.65) { // 1.6
        ar_string = "16:10";
    } else if (ar_float > 1.75 && ar_float < 1.80) { // 1.777
        ar_string = "16:9";
    } else if (ar_float > 1.88 && ar_float < 1.92) { // 1,896
        ar_string = "256:135";
    } else if (ar_float > 2.3 && ar_float < 2.4) { // 2.333
        ar_string = "21:9";
    } else if (ar_float > 3.5 && ar_float < 3.6) { // 3.555
        ar_string = "32:9";
    }
    // mobile displays // add more as we go...
    else if (ar_float === 2) { // 2
        ar_string = "18:9";
    } else if (ar_float > 2 && ar_float < 2.1) { // 2,0555
        ar_string = "18.5:9";
    } else if (ar_float > 2.1 && ar_float < 2.14) { // 2,111
        ar_string = "19:9";
    } else if (ar_float > 2.14 && ar_float < 2.2) { // 2,1666
        ar_string = "19.5:9";
    }

    if (ar_invert) {
        var splits = ar_string.split(':');
        ar_string = splits[1] + ":" + splits[0];
    }

    return ar_string;
}

/*!
 * 'video aspect ratio' to string()
 *
 * See: https://en.wikipedia.org/wiki/Aspect_ratio_(image)
 */
function varToString(width, height) {
    var ar_string = '';
    var ar_float = 1.0;
    var ar_invert = false;

    if (width >= height) {
        ar_float = width / height;
    } else {
        ar_float = height / width;
        ar_invert = true;
    }

    if (ar_float > 0.99 && ar_float < 1.01) {
        ar_string = "1:1";
    } else if (ar_float > 1.24 && ar_float < 1.26) {
        ar_string = "5:4";
    } else if (ar_float > 1.323 && ar_float < 1.343) {
        ar_string = "4:3";
    } else if (ar_float > 1.42 && ar_float < 1.44) {
        ar_string = "1.43:1";
    } else if (ar_float > 1.49 && ar_float < 1.51) {
        ar_string = "3:2";
    } else if (ar_float > 1.545 && ar_float < 1.565) {
        ar_string = "14:9";
    } else if (ar_float > 1.59 && ar_float < 1.61) {
        ar_string = "16:10";
    } else if (ar_float > 1.656 && ar_float < 1.676) {
        ar_string = "5:3";
    } else if (ar_float > 1.767 && ar_float < 1.787) {
        ar_string = "16:9";
    } else if (ar_float > 1.84 && ar_float < 1.86) {
        ar_string = "1.85:1";
    } else if (ar_float > 1.886 && ar_float < 1.906) {
        ar_string = "1.896:1";
    } else if (ar_float > 1.99 && ar_float < 2.01) {
        ar_string = "2:1";
    } else if (ar_float > 2 && ar_float < 2.1) { // mobile screenshot... 2,0555
        ar_string = "18.5:9";
    } else if (ar_float > 2.1 && ar_float < 2.14) { // mobile screenshot... 2,111
        ar_string = "19:9";
    } else if (ar_float > 2.14 && ar_float < 2.2) { // mobile screenshot... 2,1666
        ar_string = "19.5:9";
    } else if (ar_float > 2.19 && ar_float < 2.22) {
        ar_string = "2.20:1";
    } else if (ar_float > 2.34 && ar_float < 2.36) {
        ar_string = "2.35:1";
    } else if (ar_float > 2.38 && ar_float < 2.40) {
        ar_string = "2.39:1";
    } else if (ar_float > 2.54 && ar_float < 2.56) {
        ar_string = "2.55:1";
    } else if (ar_float > 2.75 && ar_float < 2.77) {
        ar_string = "2.76:1";
    } else {
        ar_string = ar_float.toFixed(2) + ":1";
    }

    if (ar_invert) {
        var splits = ar_string.split(':');
        ar_string = splits[1] + ":" + splits[0];
    }

    return ar_string;
}

/*!
 * 'video aspect ratio' to description string()
 *
 * See: https://en.wikipedia.org/wiki/Aspect_ratio_(image)
 */
function varToDescString(width, height) {
    var ar_string = '';
    var ar_float = 1.0;

    if (width >= height) {
        ar_float = width / height;
    } else {
        ar_float = height / width;
    }

    if (ar_float > 0.99 && ar_float < 1.01) {
        ar_string = qsTr("square");
    } else if (ar_float > 1.42 && ar_float < 1.44) {
        ar_string = "IMAX";
    } else if (ar_float > 1.656 && ar_float < 1.676) {
        ar_string = qsTr("35mm film");
    } else if (ar_float > 1.84 && ar_float < 1.86) {
        ar_string = qsTr("US / UK widescreen");
    } else if (ar_float > 1.886 && ar_float < 1.906) {
        ar_string = qsTr("DCI / SMPTE digital cinema");
    } else if (ar_float > 1.99 && ar_float < 2.01) {
        ar_string = "SuperScope / Univisium";
    } else if (ar_float > 2.19 && ar_float < 2.22) {
        ar_string = qsTr("70 mm film");
    } else if (ar_float > 2.34 && ar_float < 2.36) {
        ar_string = qsTr("35 mm anamorphic");
    } else if (ar_float > 2.38 && ar_float < 2.41) {
        ar_string = qsTr("35 mm modern anamorphic");
    } else if (ar_float > 2.54 && ar_float < 2.56) {
        ar_string = "Cinemascope";
    } else if (ar_float > 2.75 && ar_float < 2.77) {
        ar_string = "Ultra Panavision 70";
    }

    return ar_string;
}

/* ************************************************************************** */

/*!
 * bitrateToString()
 */
function bitrateToString(bitrate) {
    var text = '';

    if (bitrate > 0) {
        if (bitrate < 10000000) { // < 10 Mb
            text = (bitrate / 1000).toFixed(0) + " " + qsTr("Kb/s");
        } else if (bitrate < 100000000) { // < 100 Mb
            text = (bitrate / 1000 / 1000).toFixed(1) + " " + qsTr("Mb/s");
        } else if (bitrate < 1000000000) { // < 1 Gb
            text = (bitrate / 1000 / 1000).toFixed(0) + " " + qsTr("Mb/s");
        } else {
            text = (bitrate / 1000 / 1000 / 1000).toFixed(2) + " " + qsTr("Gb/s");
        }
    } else {
        text = qsTr("Unknown");
    }

    return text;
}

/*!
 * bitrateModeToString()
 */
function bitrateModeToString(bitrateMode) {
    var text = '';

    if (bitrateMode === 1)
        text = qsTr("CBR");
    else if (bitrateMode === 2)
        text = qsTr("VBR");
    else if (bitrateMode === 3)
        text = qsTr("ABR");
    else if (bitrateMode === 4)
        text = qsTr("CVBR");

    return text;
}

/*!
 * framerateToString()
 */
function framerateToString(framerate) {
    var text = '';

    if (framerate > 0) {
        text = framerate.toFixed(3) + " " + qsTr("FPS");
    } else {
        text = qsTr("Unknown");
    }

    return text;
}

/* ************************************************************************** */

/*!
 * projectionToString()
 */
function projectionToString(proj) {
    var proj_string = '';

    if (proj > 0) {
        proj_string = qsTr("spherical")

        if (proj === 1) // PROJECTION_EQUIRECTANGULAR
            proj_string += "  (" + qsTr("equirectangular") + ")";
        else if (proj === 2) // PROJECTION_EAC
            proj_string += "  (" + qsTr("EAC") + ")";
        else if (proj === 3) // PROJECTION_CUBEMAP_A
            proj_string += "  (" + qsTr("cubemap") + ")";
        else if (proj === 4) // PROJECTION_MESH
            proj_string += "  (" + qsTr("mesh") + ")";

    } else {
        proj_string = qsTr("rectangular");
    }

    return proj_string;
}

/*!
 * scanmodeToString()
 */
function scanmodeToString(scanmode) {
    var scanmode_string = '';

    if (scanmode === 1) // SCAN_PROGRESSIVE
        scanmode_string = qsTr("progressive");
    else if (scanmode === 2) // SCAN_INTERLACED
        scanmode_string = qsTr("interlaced");

    return scanmode_string;
}

/* ************************************************************************** */

/*!
 * orientationMp4ToString()
 *
 * Convert MP4 rotation enumeration to a readable string
 */
function orientationMp4ToString(rotation) {
    var text = '';

    if (rotation > 0) {
        if (rotation === 1)
            text = qsTr("Rotate 90°");
        else if (rotation === 2)
            text = qsTr("Rotate 180°");
        else if (rotation === 3)
            text = qsTr("Rotate 270°");
        else
            text = qsTr("Unknown rotation");
    } else {
        text = qsTr("No rotation");
    }

    return text;
}

/*!
 * orientationExifToString()
 *
 * Convert EXIF orientation enumeration to a readable string.
 * Rotations are clockwise.
 */
function orientationExifToString(orientation) {
    var text = '';

    if (orientation === 1)
        text = qsTr("No transformation");
    else if (orientation === 2)
        text = qsTr("Mirror");
    else if (orientation === 3)
        text = qsTr("Rotate 180°");
    else if (orientation === 4)
        text = qsTr("Flip");
    else if (orientation === 5)
        text = qsTr("Mirror and rotate 270°");
    else if (orientation === 6)
        text = qsTr("Rotate 90°");
    else if (orientation === 7)
        text = qsTr("Mirror and rotate 90");
    else if (orientation === 8)
        text = qsTr("Rotate 270");
    else
        text = qsTr("Invalid transformation");

    return text;
}

/*!
 * orientationQtToString()
 *
 * Convert Qt QImageIOHandler::Transformation enumeration to a readable string.
 * Rotations are clockwise.
 */
function orientationQtToString(orientation) {
    var text = '';

    if (orientation === 0)
            text = qsTr("No transformation");
    else if (orientation === 1)
        text = qsTr("Mirror");
    else if (orientation === 2)
        text = qsTr("Flip");
    else if (orientation === 3)
        text = qsTr("Rotate 180°");
    else if (orientation === 4)
        text = qsTr("Rotate 90°");
    else if (orientation === 5)
        text = qsTr("Mirror and rotate 90°");
    else if (orientation === 6)
        text = qsTr("Flip and rotate 90°");
    else if (orientation === 7)
        text = qsTr("Rotate 270°");
    else
        text = qsTr("Invalid transformation");

    return text;
}

/* ************************************************************************** */

/*
 * orientationToTransform_exif()
 * 1 = Horizontal (default)
 * 2 = Mirror
 * 3 = Rotate 180
 * 4 = Flip
 * 5 = Flip and rotate 90 CW
 * 6 = Rotate 90 CW // Rotate 270 CCW
 * 7 = Mirror and rotate 90 CW
 * 8 = Rotate 270 CW // Rotate 90 CCW
 *
 * rot: rotation in degree
 * hflip: true if horizontal flip / mirror is applied
 * vflip: true if vertical flip is applied
 * return an EXIF enum
 */
function orientationToTransform_exif(rot, hflip, vflip) {
    //console.log("orientationToTransform_exif(" + rot + "/" + hflip + "/" + vflip +")")

    var transform = 0

    // factorize unhandled cases
    if (hflip && vflip) { rot += 180; rot %= 360; hflip = false; vflip = false; }
    if (rot === 180 && hflip && !vflip) { rot = 0; hflip = false; vflip = true; }
    if (rot === 270 && hflip && !vflip) { rot = 90; hflip = false; vflip = true; }
    if (rot === 270 && !hflip && vflip) { rot = 90; hflip = true; vflip = false; }

    if (rot === 0 && !hflip && !vflip)
        transform = 1
    else if (rot === 0 && hflip && !vflip)
        transform = 2
    else if (rot === 180 && !hflip && !vflip)
        transform = 3
    else if (rot === 0 && !hflip && vflip)
        transform = 4
    else if (rot === 90 && !hflip && vflip)
        transform = 5
    else if (rot === 90 && !hflip && !vflip)
        transform = 6
    else if (rot === 90 && hflip && !vflip)
        transform = 7
    else if (rot === 270 && !hflip && !vflip)
        transform = 8

    return transform
}

/*
 * orientationToTransform_qt()
 * - https://doc.qt.io/qt-5/qimageiohandler.html#Transformation-enum
 *
 * rot: rotation in degree
 * hflip: true if horizontal flip / mirror is applied
 * vflip: true if vertical flip is applied
 * return an QImageIOHandler::Transformation enum
 */
function orientationToTransform_qt(rot, hflip, vflip) {
    //console.log("orientationToTransform_qt(" + rot + "/" + hflip + "/" + vflip +")")

    var transform = 0

    // factorize unhandled cases
    if (hflip && vflip) { rot += 180; rot %= 360; hflip = false; vflip = false; }
    if (rot === 180 && hflip && !vflip) { rot = 0; hflip = false; vflip = true; }
    if (rot === 270 && hflip && !vflip) { rot = 90; hflip = false; vflip = true; }
    if (rot === 270 && !hflip && vflip) { rot = 90; hflip = true; vflip = false; }

    if (rot === 0 && hflip && !vflip)
        transform = 1
    else if (rot === 0 && !hflip && vflip)
        transform = 2
    else if (rot === 180 && !hflip && !vflip)
        transform = 3
    else if (rot === 90 && !hflip && !vflip)
        transform = 4
    else if (rot === 90 && hflip && !vflip)
        transform = 5
    else if (rot === 90 && !hflip && vflip)
        transform = 6
    else if (rot === 270 && !hflip && !vflip)
        transform = 7

    return transform
}

/* ************************************************************************** */
