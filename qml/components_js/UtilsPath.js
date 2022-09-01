// UtilsPath.js
// Version 6
.pragma library

/* ************************************************************************** */

/*!
 * Take a path (url or string) and make sure we output a clean string path.
 */
function cleanUrl(pathInput) {
    var stringOut = '';

    var input = Qt.resolvedUrl(pathInput)
    if (!(typeof input === 'string' || input instanceof String)) {
        input = input.toString();
    }

    if (typeof input === 'string' || input instanceof String) {
        if (input.slice(0, 8) === "file:///") {
            var k = input.charAt(9) === ':' ? 8 : 7;
            stringOut = input.substring(k);
        } else if (input.slice(0, 10) === "content://") {
            // 'content://com.android.providers.media.documents/document/' + filename
            // 'content://' + 'app.package' + '/root/' + path
            var kk = input.indexOf("/root/"); kk += 5;
            stringOut = input.substring(kk);
        } else {
            stringOut = input;
        }
    } else {
        console.log("cleanUrl() has been given an unknown type...");
    }

    //console.log("cleanUrl() in: " + pathInput + " / out: " + stringOut)
    return stringOut;
}

/*!
 * Take a path (url or string) and make sure we output a clean url.
 */
function makeUrl(pathInput) {
    var urlOut = '';

    if (typeof pathInput === 'string' || pathInput instanceof String) {
        urlOut = "file://" + pathInput;
    }

    //console.log("makeUrl() in: " + pathInput + " / out: " + urlOut)
    return urlOut;
}

/*!
 * Take an url or string from a file, return the absolute path of the folder containing that file.
 */
function fileToFolder(filePath) {
    if (!(typeof filePath === 'string' || filePath instanceof String)) {
        filePath = filePath.toString();
    }

    var folderPath = '';
    if (typeof filePath === 'string' || filePath instanceof String) {
        folderPath = filePath.substring(0, filePath.lastIndexOf("/"));
    } else {
        console.log("fileToFolder(filePath) has been given an unknown type...");
    }

    return folderPath;
}

function openWith(filePath) {
    Qt.openUrlExternally(filePath)
}

/* ************************************************************************** */

function isMediaFile(filePath) {
    return (isVideoFile(filePath) || isAudioFile(filePath) || isPictureFile(filePath));
}

function isVideoFile(filePath) {
    if (!(typeof filePath === 'string' || filePath instanceof String)) {
        filePath = filePath.toString();
    }

    var extension = filePath.split('.').pop().toLowerCase();
    var valid = false;

    if (extension.length !== 0) {
        if (extension === "mov" || extension === "m4v" || extension === "mp4" || extension === "mp4v" ||
            extension === "3gp" || extension === "3gpp" ||
            extension === "mkv" || extension === "webm" ||
            extension === "avi" || extension === "divx" ||
            extension === "asf" || extension === "wmv" ||
            extension === "insv") {
            valid = true;
        }
    }

    return valid;
}

function isPictureFile(filePath) {
    if (!(typeof filePath === 'string' || filePath instanceof String)) {
        filePath = filePath.toString();
    }

    var extension = filePath.split('.').pop().toLowerCase();
    var valid = false;

    if (extension.length !== 0) {
        if (extension === "jpg" || extension === "jpeg" || extension === "webp" ||
            extension === "png" || extension === "gpr" ||
            extension === "gif" ||
            extension === "heif" || extension === "heic" || extension === "avif" ||
            extension === "tga" || extension === "bmp" ||
            extension === "tif" || extension === "tiff" ||
            extension === "svg" ||
            extension === "insp") {
            valid = true;
        }
    }

    return valid;
}

function isAudioFile(filePath) {
    if (!(typeof filePath === 'string' || filePath instanceof String)) {
        filePath = filePath.toString();
    }

    var extension = filePath.split('.').pop().toLowerCase();
    var valid = false;

    if (extension.length !== 0) {
        if (extension === "mp1" || extension === "mp2" || extension === "mp3" ||
            extension === "m4a" || extension === "mp4a" ||  extension === "m4r" || extension === "aac" ||
            extension === "mka" ||
            extension === "wma" ||
            extension === "flac" ||
            extension === "amb" || extension === "wav" || extension === "wave" ||
            extension === "ogg" || extension === "opus" || extension === "vorbis") {
            valid = true;
        }
    }

    return valid;
}

/* ************************************************************************** */
