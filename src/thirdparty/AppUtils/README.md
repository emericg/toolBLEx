# AppUtils

A collection of C++ helpers for (my) QML applications. Works with Qt5 and Qt6.

## Quick start

### Build

Copy the AppUtils directory into your project, then include the library files with
either the `AppUtils.pro` QMake project file or the `CMakeLists.txt` CMake project file.

```qmake
include(src/thirdparty/AppUtils/AppUtils.pri)
```

```cmake
add_subdirectory(src/thirdparty/AppUtils)
target_link_libraries(${PROJECT_NAME} AppUtils::AppUtils)
```

### Register

Registering the QML type in C++ in your main.cpp file:

```cpp
#include <utils_app.h>
#include <utils_screen.h>

int main(int argc, char *argv[])
{
    UtilsApp *utilsApp = UtilsApp::getInstance();
    UtilsScreen *utilsScreen = UtilsScreen::getInstance(&app);

    QQmlApplicationEngine engine;
    QQmlContext *engine_context = engine.rootContext();

    engine_context->setContextProperty("utilsApp", utilsApp);
    engine_context->setContextProperty("utilsScreen", utilsScreen);
    
    return app.exec();
}
```

### Usage

TODO

## License

AppUtils is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.  
Read the [LICENSE](LICENSE.md) file or [consult the license on the FSF website](https://www.gnu.org/licenses/gpl-3.0.txt) directly.

> Emeric Grange <emeric.grange@gmail.com>
