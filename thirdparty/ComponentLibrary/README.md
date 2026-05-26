# ComponentLibrary

## About

A Qt6 / QML component library.

#### Prerequisites

> find_package(Qt6 REQUIRED COMPONENTS Svg Qml Quick QuickControls2 LabsQmlModels)

- Core
- Qml
- Quick
- QuickControls2
- Svg               (for generic/IconSvg.qml)
- LabsQmlModels     (for menus/ActionMenu_*.qml, and their DelegateChooser)

> find_package(Qt6 OPTIONAL COMPONENTS Location)

- Location          (for maps/Map*.qml components)

#### Include in your projects

Either:
- include the CMakeLists.txt project file (and use qml_add_modules())
- include the ComponentLibrary.qrc resource file directly

For both methods, you should add the **find_package()** mentionned above to your ROOT CMake project file.

To ensure the application deployment process doesn't miss the necessary QML modules,
you should also copy the **QmlImports.qml** file (or its content) in the path that 
will be scanned by the linuxdeploy/macdeployqt/windowdeployqt and the qmlimportscanner.

##### Using the CMakeLists.txt

```cmake
add_subdirectory(thirdparty/ComponentLibrary)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ComponentLibraryplugin)
```

And with a couple of hacks that nobody can tell you why they are necessary:

```cmake
set(QML_IMPORT_PATH
    "${CMAKE_BINARY_DIR}/thirdparty/"
    "${CMAKE_BINARY_DIR}/thirdparty/ComponentLibrary"
    CACHE STRING "QML Modules import paths" FORCE)

set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
```

##### Using the ComponentLibrary.qrc (oldschool)

```cmake
qt_add_executable(${CMAKE_PROJECT_NAME}
    src/main.cpp
    thirdparty/ComponentLibrary/ComponentLibrary.qrc)
```

And register the ThemeEngine singleton manually in your ```main.cpp```:

```cpp
qmlRegisterSingletonType(QUrl("qrc:/ComponentLibrary/ThemeEngine.qml"), "ComponentLibrary", 1, 0, "Theme");
```
