# SingleApplication

SingleApplication is a replacement of the QtSingleApplication. Works with Qt5 and Qt6.

Keeps the Primary Instance of your Application and kills each subsequent
instances. It can (if enabled) spawn secondary (non-related to the primary)
instances and can send data to the primary instance from secondary instances.

This README is just a quick start guide, you can find everything on the project official GitHub page and documentation:

> https://github.com/itay-grudev/SingleApplication  

> https://itay-grudev.github.io/SingleApplication/classSingleApplication.html  

## Quick start

### Build

Copy the SingleApplication directory into your project, then include the library files
with either the `SingleApplication.pro` QMake project file or the `CMakeLists.txt` CMake project file.

```qmake
include(src/thirdparty/SingleApplication/SingleApplication.pri)
DEFINES += QAPPLICATION_CLASS=QGuiApplication
```

```cmake
add_subdirectory(src/thirdparty/SingleApplication)
set(QAPPLICATION_CLASS QGuiApplication)
target_link_libraries(${PROJECT_NAME} SingleApplication::SingleApplication)
```

### Usage

The `SingleApplication` class inherits from whatever `Q[Core|Gui]Application`
class you specify via the `QAPPLICATION_CLASS` macro (`QCoreApplication` is the
default). Further usage is similar to the use of the `Q[Core|Gui]Application` classes.

> QCoreApplication - base class. Use it in command line applications  
> QGuiApplication - base class + GUI capabilities. Use it in QML applications  
> QApplication - base class + GUI + support for widgets. Use it in QtWidgets applications  

You can use the library as if you were using any other `QCoreApplication` derived class:

```cpp
#include <SingleApplication>

int main(int argc, char* argv[])
{
    SingleApplication app(argc, argv);

    return app.exec();
}
```

## License

This project is licensed under the MIT license, see LICENSE file for details.
