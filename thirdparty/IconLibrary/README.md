# IconLibrary


## Quick start

### Build

```cmake
qt_add_executable(${PROJECT_NAME}
    src/main.cpp
    thirdparty/IconLibrary/IconLibrary_material.qrc
)
```

### Use

```qml
Image {
    source: "qrc:/IconLibrary/material-symbols/info-fill.svg"
}
```

## License
