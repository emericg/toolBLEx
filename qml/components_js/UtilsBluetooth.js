// UtilsBluetooth.js
// Version 2

/* ************************************************************************** */

function getBluetoothCoreConfigurationText(coreConfiguration) {
    if (coreConfiguration === 1) return qsTr("Low Energy")
    if (coreConfiguration === 2) return qsTr("Classic")
    if (coreConfiguration === 3) return qsTr("Classic & Low Energy")
    return ""
}

/* ************************************************************************** */

function getBluetoothAdapterModeText(mode) {
    if (mode === 0) return qsTr("Powered down")
    if (mode === 1) return qsTr("Connectable")
    if (mode === 2) return qsTr("Discoverable")
    if (mode === 3) return qsTr("Discoverable (limited)")
    return qsTr("Unknown")
}

/* ************************************************************************** */

function getBluetoothPairingText(pairing) {
    if (pairing === 0) return qsTr("Unpaired")
    if (pairing === 2) return qsTr("Paired")
    if (pairing === 3) return qsTr("Paired (authorized)")
    return qsTr("Unknown")
}

/* ************************************************************************** */

function getBluetoothMajorClassIcon(majorClass) {
    if (majorClass === 1) return "qrc:/IconLibrary/bootstrap/laptop.svg"
    if (majorClass === 2) return "qrc:/IconLibrary/bootstrap/phone.svg"
    if (majorClass === 3) return "qrc:/IconLibrary/bootstrap/router.svg"
    if (majorClass === 4) return "qrc:/IconLibrary/bootstrap/speaker.svg"
    if (majorClass === 5) return "qrc:/IconLibrary/bootstrap/keyboard.svg"
    if (majorClass === 6) return "qrc:/IconLibrary/bootstrap/printer.svg"
    if (majorClass === 7) return "qrc:/IconLibrary/bootstrap/smartwatch.svg"
    if (majorClass === 8) return "qrc:/IconLibrary/bootstrap/joystick.svg"
    if (majorClass === 9) return "qrc:/IconLibrary/bootstrap/heart-pulse.svg"
    return ""
}

function getBluetoothMajorClassText(majorClass) {
    if (majorClass === 0) return qsTr("Miscellaneous device")
    if (majorClass === 1) return qsTr("Computer")
    if (majorClass === 2) return qsTr("Phone")
    if (majorClass === 3) return qsTr("Network device")
    if (majorClass === 4) return qsTr("Audio Video device")
    if (majorClass === 5) return qsTr("Peripheral")
    if (majorClass === 6) return qsTr("Imaging device")
    if (majorClass === 7) return qsTr("Wearable device")
    if (majorClass === 8) return qsTr("Toy")
    if (majorClass === 9) return qsTr("Health device")
    if (majorClass === 31) return qsTr("Uncategorized")
    return ""
}

/* ************************************************************************** */

function getBluetoothMinorClassIcon(majorClass, minorClass) {
    if (majorClass === 1) { // Computer

        if (minorClass === 1) return "qrc:/IconLibrary/bootstrap/pc.svg"
        if (minorClass === 2) return "qrc:/IconLibrary/bootstrap/pc.svg"
        if (minorClass === 3) return "qrc:/IconLibrary/bootstrap/laptop.svg"
        if (minorClass === 6) return "qrc:/IconLibrary/bootstrap/smartwatch.svg"

    } else if (majorClass === 2) { // Phone

        if (minorClass === 1) return "qrc:/IconLibrary/bootstrap/phone.svg"
        if (minorClass === 2) return "qrc:/IconLibrary/bootstrap/telephone.svg"
        if (minorClass === 3) return "qrc:/IconLibrary/bootstrap/phone.svg"
        if (minorClass === 4) return "qrc:/IconLibrary/bootstrap/modem.svg"
        if (minorClass === 5) return "qrc:/IconLibrary/bootstrap/telephone.svg"

    } else if (majorClass === 4) { // Audio Video

        if (minorClass === 1) return "qrc:/IconLibrary/bootstrap/headset.svg"
        if (minorClass === 2) return "qrc:/IconLibrary/bootstrap/headset.svg"
        if (minorClass === 4) return "qrc:/IconLibrary/bootstrap/mic.svg"
        if (minorClass === 5) return "qrc:/IconLibrary/bootstrap/speaker.svg"
        if (minorClass === 6) return "qrc:/IconLibrary/bootstrap/headphones.svg"
        if (minorClass === 7) return "qrc:/IconLibrary/bootstrap/boombox.svg"
        if (minorClass === 8) return "qrc:/IconLibrary/bootstrap/car-front-fill.svg"
        if (minorClass === 9) return "qrc:/IconLibrary/bootstrap/cast.svg"
        if (minorClass === 10) return "qrc:/IconLibrary/bootstrap/boombox.svg"
        if (minorClass === 11) return "qrc:/IconLibrary/bootstrap/cassette.svg"
        if (minorClass === 12) return "qrc:/IconLibrary/bootstrap/camera-reels.svg"
        if (minorClass === 13) return "qrc:/IconLibrary/bootstrap/camera-reels.svg"
        if (minorClass === 14) return "qrc:/IconLibrary/bootstrap/tv.svg"
        if (minorClass === 15) return "qrc:/IconLibrary/bootstrap/tv.svg"
        if (minorClass === 16) return "qrc:/IconLibrary/bootstrap/webcam.svg"
        if (minorClass === 18) return "qrc:/IconLibrary/bootstrap/joystick.svg"

    } else if (majorClass === 5) { // Peripheral

        if (minorClass === 0x10) return "qrc:/IconLibrary/bootstrap/keyboard.svg"
        if (minorClass === 0x20) return "qrc:/IconLibrary/bootstrap/mouse.svg"
        if (minorClass === 0x30) return "qrc:/IconLibrary/bootstrap/keyboard.svg"

        if (minorClass === 1) return "qrc:/IconLibrary/bootstrap/joystick.svg"
        if (minorClass === 2) return "qrc:/IconLibrary/bootstrap/controller.svg"
        if (minorClass === 3) return "qrc:/IconLibrary/bootstrap/dpad.svg"
        if (minorClass === 4) return "qrc:/IconLibrary/bootstrap/thermometer-half.svg"
        if (minorClass === 5) return "qrc:/IconLibrary/bootstrap/pencil.svg"
        if (minorClass === 6) return "qrc:/IconLibrary/bootstrap/credit-card.svg"

    } else if (majorClass === 6) { // Imaging device

        if (minorClass & 0x04) return "qrc:/IconLibrary/bootstrap/tv.svg"
        if (minorClass & 0x08) return "qrc:/IconLibrary/bootstrap/webcam.svg"
        if (minorClass & 0x10) return "qrc:/IconLibrary/bootstrap/printer.svg"
        if (minorClass & 0x20) return "qrc:/IconLibrary/bootstrap/printer.svg"

    } else if (majorClass === 7) { // Wearable device

        if (minorClass === 1) return "qrc:/IconLibrary/bootstrap/smartwatch.svg"
        if (minorClass === 5) return "qrc:/IconLibrary/bootstrap/eyeglasses.svg"

    } else if (majorClass === 8) { // Toy

        if (minorClass === 1) return "qrc:/IconLibrary/bootstrap/robot.svg"
        if (minorClass === 2) return "qrc:/IconLibrary/bootstrap/car-front-fill.svg"
        if (minorClass === 4) return "qrc:/IconLibrary/bootstrap/controller.svg"

    } else if (majorClass === 9) { // Health device

        if (minorClass === 2) return "qrc:/IconLibrary/bootstrap/thermometer-half.svg"

    }

    return getBluetoothMajorClassIcon(majorClass)
}

function getBluetoothMinorClassText(majorClass, minorClass) {
    var txt = qsTr("Uncategorized")

    if (majorClass === 1) { // Computer

        if (minorClass === 1) return qsTr("Desktop")
        if (minorClass === 2) return qsTr("Server")
        if (minorClass === 3) return qsTr("Laptop")
        if (minorClass === 4) return qsTr("Handheld (Clam Shell)")
        if (minorClass === 5) return qsTr("Handheld")
        if (minorClass === 6) return qsTr("Wearable")

    } else if (majorClass === 2) { // Phone

        if (minorClass === 1) return qsTr("Cellular")
        if (minorClass === 2) return qsTr("Cordless")
        if (minorClass === 3) return qsTr("SmartPhone")
        if (minorClass === 4) return "WiredModemOrVoiceGatewayPhone"
        if (minorClass === 5) return "CommonIsdnAccessPhone"

    } else if (majorClass === 3) { // Network device

        return qsTr("Network device")

    } else if (majorClass === 4) { // Audio Video

        if (minorClass === 1) return qsTr("Wearable headset")
        if (minorClass === 2) return qsTr("Hands free device")
        if (minorClass === 4) return qsTr("Microphone")
        if (minorClass === 5) return qsTr("Loudspeaker")
        if (minorClass === 6) return qsTr("Headphones")
        if (minorClass === 7) return qsTr("Portable audio device")
        if (minorClass === 8) return qsTr("Car audio")
        if (minorClass === 9) return qsTr("SetTopBox")
        if (minorClass === 10) return qsTr("HiFi audio")
        if (minorClass === 11) return qsTr("VCR")
        if (minorClass === 12) return qsTr("Video camera")
        if (minorClass === 13) return qsTr("Camcorder")
        if (minorClass === 14) return qsTr("Video monitor")
        if (minorClass === 15) return qsTr("Video display & Loudspeaker")
        if (minorClass === 16) return qsTr("VideoConferencing")
        if (minorClass === 18) return qsTr("Gaming device")

    } else if (majorClass === 5) { // Peripheral

        if (minorClass === 0x10) return qsTr("Keyboard")
        if (minorClass === 0x20) return qsTr("Pointing device")
        if (minorClass === 0x30) return qsTr("Keyboard with Pointing device")

        if (minorClass === 1) return qsTr("Joystick")
        if (minorClass === 2) return qsTr("Gamepad")
        if (minorClass === 3) return qsTr("Remote control")
        if (minorClass === 4) return qsTr("Sensing device")
        if (minorClass === 5) return qsTr("Pen tablet")
        if (minorClass === 6) return qsTr("Card reader")

    } else if (majorClass === 6) { // Imaging device

        if (minorClass & 0x04) {
            if (txt.length) txt += ", "
            txt += qsTr("Display")
        }
        if (minorClass & 0x08) {
            if (txt.length) txt += ", "
            txt +=  qsTr("Camera")
        }
        if (minorClass & 0x10) {
            if (txt.length) txt += ", "
            txt +=  qsTr("Scanner")
        }
        if (minorClass & 0x20) {
            if (txt.length) txt += ", "
            txt +=  qsTr("Printer")
        }

    } else if (majorClass === 7) { // Wearable device

        if (minorClass === 1) return qsTr("Wrist watch")
        if (minorClass === 2) return qsTr("Pager")
        if (minorClass === 3) return qsTr("Jacket")
        if (minorClass === 4) return qsTr("Helmet")
        if (minorClass === 5) return qsTr("Glasses")

    } else if (majorClass === 8) { // Toy

        if (minorClass === 1) return qsTr("Robot")
        if (minorClass === 2) return qsTr("Vehicle")
        if (minorClass === 3) return qsTr("Doll")
        if (minorClass === 4) return qsTr("Controller")
        if (minorClass === 5) return qsTr("Game")

    } else if (majorClass === 9) { // Health device

        if (minorClass === 1) return qsTr("Blood pressure monitor")
        if (minorClass === 2) return qsTr("Thermometer")
        if (minorClass === 3) return qsTr("Weight scale")
        if (minorClass === 4) return qsTr("Glucose meter")
        if (minorClass === 5) return qsTr("Pulse oximeter")
        if (minorClass === 7) return qsTr("Data display")
        if (minorClass === 8) return qsTr("Step counter")

    }

    //if (txt.length === 0) return getBluetoothMajorClassText(majorClass)
    return txt
}

function getBluetoothServiceClassText(serviceClass) {
    var txt = ""

    if (serviceClass & 0x0001) {
        if (txt.length) txt += ", "
        txt += qsTr("PositioningService")
    }
    if (serviceClass & 0x0002) {
        if (txt.length) txt += ", "
        txt += qsTr("NetworkingService")
    }
    if (serviceClass & 0x0004) {
        if (txt.length) txt += ", "
        txt += qsTr("RenderingService")
    }
    if (serviceClass & 0x0008) {
        if (txt.length) txt += ", "
        txt += qsTr("CapturingService")
    }
    if (serviceClass & 0x0010) {
        if (txt.length) txt += ", "
        txt += qsTr("ObjectTransferService")
    }
    if (serviceClass & 0x0020) {
        if (txt.length) txt += ", "
        txt += qsTr("AudioService")
    }
    if (serviceClass & 0x0040) {
        if (txt.length) txt += ", "
        txt += qsTr("TelephonyService")
    }
    if (serviceClass & 0x0080) {
        if (txt.length) txt += ", "
        txt += qsTr("InformationService")
    }

    return txt
}

/* ************************************************************************** */
