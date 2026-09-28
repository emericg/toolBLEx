import QtQuick

import ComponentLibrary

/*!
 * \qmltype SliderGraduation
 * \brief Optional ticks drawn alongside a slider track.
 *
 * A reusable overlay that renders graduation ticks for any T.Slider-like control (Slider, MiddleSlider, RangeSlider).
 * Placed either "below" (default) or "above" the body. Horizontal only.
 *
 * The host slider keeps ownership of its padding. But it can reserve space to better fit the ticks using:
 * \c {topPadding: base + reservedAbove} and \c {bottomPadding: base + reservedBelow}
 *
 * - Enable with 'graduation: true'
 * - Set a default value with 'graduationDefault: true' and 'graduationDefaultValue_first: 0.5'
 * - Set "regular" ticks with 'graduationStepSize: 0.1'
 * - OR set "custom" ticks with 'graduationTicks: [0, 0.1, 0.2, 0.4, 0.8, 1.0]'
 */
Item {
    id: graduationLayer

    z: -1
    visible: _gradOn
    opacity: (slider && slider.enabled) ? 1 : 0.66

    ////////

    // The slider this overlay apply to. MUST be set by the caller.
    property Item slider
    property real sliderHandleWidth: 18

    ////////

    property bool graduation: false // show graduations
    property real graduationFrom: slider ? slider.from : 0
    property real graduationStepSize: slider ? slider.stepSize : 0

    property var graduationTicks: [] // use explicit custom tick values, instead of graduationStepSize

    property bool graduationDefault: false // show default tick(s)
    property real graduationDefaultValue_first: slider ? slider.from : 0
    property real graduationDefaultValue_second: graduationDefaultValue_first

    ////////

    property string graduationPosition: "below" // as "above", so "below"
    property int graduationTickLength: 6
    property color graduationColor: Theme.colorSeparator
    property color graduationColorDefault: Theme.colorPrimary

    readonly property int reservedAbove: _gradAbove ? _gradArea : 0
    readonly property int reservedBelow: _gradBelow ? _gradArea : 0

    ////////

    readonly property bool _gradOn: slider && slider.horizontal && (graduation || graduationDefault)
    readonly property bool _gradBelow: _gradOn && graduationPosition !== "above"
    readonly property bool _gradAbove: _gradOn && graduationPosition === "above"
    readonly property int _gradArea: graduationTickLength + 6 // tick length + a gap

    readonly property real _gradStep: (graduationStepSize > 0) ? graduationStepSize
                                                               : (slider && slider.stepSize > 0 ? slider.stepSize : 0)
    readonly property int _gradCount: (slider && graduation && _gradStep > 0 && slider.to > graduationFrom)
                                            ? Math.floor((slider.to - graduationFrom) / _gradStep + 1e-6) + 1 : 0

    readonly property real _trackCenter: slider ? slider.topPadding + (slider.availableHeight / 2) : 0
    readonly property real _tickTop: _gradAbove ? (_trackCenter - (sliderHandleWidth / 2) - 0 - graduationTickLength)
                                                : (_trackCenter + (sliderHandleWidth / 2) + 0)

    readonly property bool _explicitTicks: graduationTicks && graduationTicks.length > 0

    // The x of a value's tick, aligned to where the handle centers on it
    function graduationValueToX(value) {
        if (!slider) return 0
        let t = (slider.to > slider.from) ? (value - slider.from) / (slider.to - slider.from) : 0
        if (slider.mirrored) t = 1 - t
        return slider.leftPadding + t * (slider.availableWidth - sliderHandleWidth) + (sliderHandleWidth / 2)
    }

    ////////////////

    Repeater { // the full scale, or the explicit tick list when one is given
        model: graduationLayer._explicitTicks
               ? (graduationLayer.graduation ? graduationLayer.graduationTicks : [])
               : graduationLayer._gradCount

        Rectangle {
            readonly property real tickValue: graduationLayer._explicitTicks
                                              ? modelData
                                              : graduationLayer.graduationFrom + index * graduationLayer._gradStep

            width: 2
            height: graduationLayer.graduationTickLength

            visible: graduationLayer.slider
                     && tickValue >= graduationLayer.slider.from
                     && tickValue <= graduationLayer.slider.to
            x: graduationLayer.graduationValueToX(tickValue) - (width / 2)
            y: graduationLayer._tickTop
            color: graduationLayer.graduationColor
        }
    }

    ////////////////

    Rectangle { // the default-value tick
        width: 2
        height: graduationLayer.graduationTickLength + 3

        visible: graduationLayer.graduationDefault
        x: graduationLayer.graduationValueToX(graduationLayer.graduationDefaultValue_first) - (width / 2)
        y: graduationLayer._gradAbove ? (graduationLayer._tickTop - 3) : graduationLayer._tickTop
        color: graduationLayer.graduationColorDefault
    }

    Rectangle { // the second default-value tick, for RangeSlider
        width: 2
        height: graduationLayer.graduationTickLength + 3

        visible: graduationLayer.graduationDefault &&
                 graduationLayer.graduationDefaultValue_second !== graduationLayer.graduationDefaultValue_first
        x: graduationLayer.graduationValueToX(graduationLayer.graduationDefaultValue_second) - (width / 2)
        y: graduationLayer._gradAbove ? (graduationLayer._tickTop - 3) : graduationLayer._tickTop
        color: graduationLayer.graduationColorDefault
    }

    ////////////////
}
