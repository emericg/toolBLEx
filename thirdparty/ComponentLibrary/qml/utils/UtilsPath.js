// UtilsPath.js
.pragma library

/* ************************************************************************** */

/*!
 * Take a path (url or string) and make sure we output a clean string path.
 */
function cleanUrl(pathInput) {
    var stringOut = '';

    const input = Qt.resolvedUrl(pathInput).toString();

    if (input.slice(0, 8) === "file:///") {
        const k = input.charAt(9) === ':' ? 8 : 7;
        stringOut = input.substring(k);
    } else if (input.slice(0, 10) === "content://") {
        // 'content://com.android.providers.media.documents/document/' + filename
        // 'content://' + 'app.package' + '/root/' + path
        const kk = input.indexOf("/root/") + 5;
        stringOut = input.substring(kk);
    } else {
        stringOut = input;
    }

    //console.log("cleanUrl() in: " + pathInput + " / out: " + stringOut)
    return stringOut;
}

/*!
 * Take a local path (url or string) and make sure we output a clean url.
 * Scheme detection requires 2+ chars before ':', so a Windows drive ("C:")
 * is still treated as a local path.
 */
function makeUrl(pathInput) {
    if (!(typeof pathInput === 'string' || pathInput instanceof String)) {
        return pathInput;
    }

    var urlOut = pathInput;

    if (!/^[a-zA-Z][a-zA-Z0-9+.-]+:/.test(pathInput)) {
        // Always emit a 'file:///' (triple-slash) url, matching cleanUrl():
        // - unix    "/home/x" -> "file:///home/x"
        // - windows "C:/x"    -> "file:///C:/x"
        urlOut = "file://" + (pathInput.charAt(0) === '/' ? pathInput : '/' + pathInput);
    }

    //console.log("makeUrl() in: " + pathInput + " / out: " + urlOut)
    return urlOut;
}

/*!
 * Take an url or string from a file, return the absolute path of the folder containing that file.
 */
function fileToFolder(filePath) {
    if (!filePath) return '';

    filePath = filePath.toString();
    return filePath.substring(0, filePath.lastIndexOf("/"));
}

/*!
 * Take an url or string from a file, return the file name (with its extension).
 */
function getFileName(filePath) {
    if (!filePath) return '';

    filePath = filePath.toString();
    return filePath.substring(filePath.lastIndexOf("/") + 1);
}

/*!
 * Take an url or string from a file, return its lowercased extension (without the dot).
 * Returns '' when there is no extension.
 */
function getFileExtension(filePath) {
    if (!filePath) return '';

    filePath = filePath.toString();
    var lastDot = filePath.lastIndexOf(".");
    var lastSlash = filePath.lastIndexOf("/");
    if (lastDot <= lastSlash + 1) return ''; // no dot, or dot belongs to a folder / dotfile

    return filePath.substring(lastDot + 1).toLowerCase();
}

function openWith(filePath) {
    Qt.openUrlExternally(filePath)
}

/* ************************************************************************** */

function isMediaFile(filePath) {
    if (!filePath) return false
    return (isVideoFile(filePath) || isAudioFile(filePath) || isPictureFile(filePath));
}

function isVideoFile(filePath) {
    if (!filePath) return false

    var extension = getFileExtension(filePath);
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
    if (!filePath) return false

    var extension = getFileExtension(filePath);
    var valid = false;

    if (extension.length !== 0) {
        if (extension === "jpg" || extension === "jpeg" ||
            extension === "jp2" || extension === "j2k" || extension === "jxl" ||
            extension === "webp" ||
            extension === "png" || extension === "gpr" ||
            extension === "gif" ||
            extension === "avif" || extension === "heif" || extension === "heic" ||
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
    if (!filePath) return false

    var extension = getFileExtension(filePath);
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

function isDocumentFile(filePath) {
    if (!filePath) return false

    var extension = getFileExtension(filePath);
    var valid = false;

    if (extension.length !== 0) {
        if (extension === "pdf" ||
            //plain text
            extension === "txt" || extension === "md" || extension === "rtf" ||
            // office docs
            extension === "doc" || extension === "docx" || extension === "odt" ||
            extension === "xls" || extension === "xlsx" || extension === "ods" || extension === "csv" ||
            extension === "ppt" || extension === "pptx" || extension === "odp" ||
            extension === "pages" || extension === "numbers" || extension === "key" ||
            // e-books
            extension === "epub" || extension === "mobi" || extension === "azw" || extension === "azw3") {
            valid = true;
        }
    }

    return valid;
}

function isArchiveFile(filePath) {
    if (!filePath) return false

    var extension = getFileExtension(filePath);
    var valid = false;

    if (extension.length !== 0) {
        if (extension === "zip" || extension === "rar" || extension === "7z" ||
            // tarballs
            extension === "tar" || extension === "tgz" || extension === "tbz2" || extension === "txz" ||
            // compressors
            extension === "gz" || extension === "bz2" || extension === "xz" || extension === "lz" ||
            extension === "lzma" || extension === "zst" || extension === "z" ||
            // packages
            extension === "arj" || extension === "ace" || extension === "cab" || extension === "iso" ||
            extension === "deb" || extension === "rpm") {
            valid = true;
        }
    }

    return valid;
}

/* ************************************************************************** */
