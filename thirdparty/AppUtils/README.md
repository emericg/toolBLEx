# AppUtils

A collection of C++ helpers for (my) QML applications.

## Quick start

### Build

Copy the AppUtils directory into your project, then include the library files
using the `CMakeLists.txt` CMake project file.

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

This project is licensed under the MIT license, see LICENSE file for details.

> Emeric Grange <emeric.grange@gmail.com>
