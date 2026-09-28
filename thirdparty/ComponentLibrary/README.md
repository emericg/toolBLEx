# ComponentLibrary

A Qt6 / QML component library.


## Quick start

### Prerequisites

> find_package(Qt6 REQUIRED COMPONENTS Svg Qml Quick QuickControls2 LabsQmlModels)

- Core
- Qml
- Quick
- QuickControls2
- Svg               (for generic/IconSvg.qml)
- LabsQmlModels     (for menus/ActionMenu_*.qml, and their DelegateChooser)

> find_package(Qt6 OPTIONAL COMPONENTS Location)

- Location          (for maps/Map*.qml components)

### Build

To get started, simply checkout the ComponentLibrary repository as a submodule, or copy the
ComponentLibrary directory into your project, then include the `CMakeLists.txt` CMake project file:

```cmake
add_subdirectory(ComponentLibrary/)
target_link_libraries(${PROJECT_NAME} PRIVATE ComponentLibrary ComponentLibrary_plugin)
```

You should add the **find_package()** mentionned above to your ROOT CMake project file.

To ensure the application deployment process doesn't miss the necessary QML modules,
you should also copy the **QmlImports.qml** file (or its content) in the path that 
will be scanned by the linuxdeploy/macdeployqt/windowdeployqt and the qmlimportscanner.

You might need some hacks so the QML Language Server recognize the ComponentLibrary module:

```cmake
set(QML_IMPORT_PATH "${CMAKE_BINARY_DIR}/ComponentLibrary/" CACHE STRING "QML Modules import paths" FORCE)
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
```

### Use

#### QML

```qml
import QtQuick
import ComponentLibrary

Item {
    width: 640
    height: 480

    ButtonClear {
        anchor.centerIn: parent

        text: "Click Me"
        onClicked: doSomething()
    }
}
```

#### Translations

The library ships its own translations catalog, embedded in its own resources.

The host application must install at runtime a QTranslator for this catalog:

```cpp
QTranslator t;
t.load(":/i18n/ComponentLibrary_" + <lang> + ".qm");
qApp->installTranslator(&t);
```


## License

This project is licensed under the [MIT license](LICENSE.md).

> Copyright (c) Emeric Grange <emeric.grange@gmail.com>
