# IconLibrary

A collection of icons, ready to use, embedded into your application binary.

- Bootstrap icons
- FontAwesome icons
- Lucide icons
- Material icons (legacy)
- Material symbols


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

IconLibrary uses a combination of licenses, see [COPYING](COPYING)
