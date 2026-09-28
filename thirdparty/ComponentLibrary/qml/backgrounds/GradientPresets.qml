pragma Singleton

import QtQuick

QtObject {
    id: gradientPresets

    ////////////////////////////////////////////////////////////////////////////

    enum GradientType {
        Linear,
        Radial
    }

    readonly property var sunset: [
        { position: 0.0, color: "#ff512f" },
        { position: 1.0, color: "#dd2476" }
    ]
    readonly property var ocean: [
        { position: 0.0, color: "#2193b0" },
        { position: 1.0, color: "#6dd5ed" }
    ]
    readonly property var forest: [
        { position: 0.0, color: "#11998e" },
        { position: 1.0, color: "#38ef7d" }
    ]
    readonly property var grape: [
        { position: 0.0, color: "#6a11cb" },
        { position: 1.0, color: "#2575fc" }
    ]
    readonly property var peach: [
        { position: 0.0, color: "#ffecd2" },
        { position: 1.0, color: "#fcb69f" }
    ]
    readonly property var mango: [
        { position: 0.0, color: "#ffe259" },
        { position: 1.0, color: "#ffa751" }
    ]
    readonly property var candy: [
        { position: 0.0, color: "#ff6a88" },
        { position: 0.5, color: "#ff99ac" },
        { position: 1.0, color: "#ffb3c1" }
    ]
    readonly property var aurora: [
        { position: 0.0, color: "#00c3ff" },
        { position: 0.5, color: "#77e190" },
        { position: 1.0, color: "#ffff1c" }
    ]
    readonly property var midnight: [
        { position: 0.0, color: "#232526" },
        { position: 1.0, color: "#414345" }
    ]
    readonly property var ember: [
        { position: 0.0, color: "#f83600" },
        { position: 1.0, color: "#fe8c00" }
    ]
    readonly property var lavender: [
        { position: 0.0, color: "#a18cd1" },
        { position: 1.0, color: "#fbc2eb" }
    ]
    readonly property var steel: [
        { position: 0.0, color: "#bdc3c7" },
        { position: 1.0, color: "#2c3e50" }
    ]
    readonly property var coral: [
        { position: 0.0, color: "#ff7e5f" },
        { position: 1.0, color: "#feb47b" }
    ]
    readonly property var lagoon: [
        { position: 0.0, color: "#43cea2" },
        { position: 1.0, color: "#185a9d" }
    ]
    readonly property var violet: [
        { position: 0.0, color: "#8e2de2" },
        { position: 1.0, color: "#4a00e0" }
    ]
    readonly property var sky: [
        { position: 0.0, color: "#56ccf2" },
        { position: 1.0, color: "#2f80ed" }
    ]
    readonly property var rose: [
        { position: 0.0, color: "#ee9ca7" },
        { position: 1.0, color: "#ffdde1" }
    ]
    readonly property var emerald: [
        { position: 0.0, color: "#348f50" },
        { position: 1.0, color: "#56b4d3" }
    ]
    readonly property var cosmic: [
        { position: 0.0, color: "#ff00cc" },
        { position: 1.0, color: "#333399" }
    ]
    readonly property var slate: [
        { position: 0.0, color: "#0f2027" },
        { position: 0.5, color: "#203a43" },
        { position: 1.0, color: "#2c5364" }
    ]

    ////////////////////////////////////////////////////////////////////////////

    /*!
     * \brief Ordered list of every preset name.
     */
    readonly property var names: [
        "sunset", "ocean", "forest", "grape",
        "peach", "mango", "candy", "aurora",
        "midnight", "ember", "lavender", "steel",
        "coral", "lagoon", "violet", "sky",
        "rose", "emerald", "cosmic", "slate"
    ]

    /*!
     * \brief Return a preset stop array by name.
     * \param name The preset name, as listed in \c names.
     * \return The matching stop array, or an empty array if unknown.
     */
    function preset(name) {
        return gradientPresets.hasOwnProperty(name) ? gradientPresets[name] : []
    }

    ////////////////////////////////////////////////////////////////////////////
}
