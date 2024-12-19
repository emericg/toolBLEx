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

For both methods, you should add the **find_package()** mentionned above to your ROOT cmake project file.

To ensure the application deployment process doesn't miss the necessary QML modules,
you should also copy the **QmlImports.qml** file (or its content) in the path that 
will be scanned by the linuxdeploy/macdeployqt/windowdeployqt and the qmlimportscanner.

You should add the ComponentLibrary import path in your ```main.cpp```:

```cpp
QQmlApplicationEngine engine;
engine.addImportPath(":/ComponentLibrary");
```

##### Using the CMakeLists.txt

```cmake
add_subdirectory(thirdparty/ComponentLibrary)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ComponentLibraryplugin)
```

##### Using the ComponentLibrary.qrc

```cmake
qt_add_executable(${CMAKE_PROJECT_NAME}
    src/main.cpp
    thirdparty/ComponentLibrary/ComponentLibrary.qrc)
```

And register the ThemeEngine singleton manually in your ```main.cpp```:

```cpp
qmlRegisterSingletonType(QUrl("qrc:/ComponentLibrary/ThemeEngine.qml"), "ComponentLibrary", 1, 0, "Theme");
```
