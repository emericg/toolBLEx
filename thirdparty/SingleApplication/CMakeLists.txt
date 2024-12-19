project(SingleApplication LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

################################################################################

if(NOT QAPPLICATION_CLASS)
    if(IOS OR ANDROID)
        message("QAPPLICATION_CLASS is not set, using default for mobile: QGuiApplication")
        set(QAPPLICATION_CLASS QGuiApplication)
    else()
        set(QAPPLICATION_CLASS QApplication)
        message("QAPPLICATION_CLASS is not set, using default for desktop: QApplication")
    endif()
endif()

################################################################################

# Dependencies
set(CORE_COMPONENTS Core Network)
set(CORE_LIBRARIES Qt6::Core Qt6::Network)

if(QAPPLICATION_CLASS STREQUAL QApplication)
    list(APPEND CORE_COMPONENTS Widgets)
    list(APPEND CORE_LIBRARIES Qt6::Widgets)
elseif(QAPPLICATION_CLASS STREQUAL QGuiApplication)
    list(APPEND CORE_COMPONENTS Gui)
    list(APPEND CORE_LIBRARIES Qt6::Gui)
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS ${CORE_COMPONENTS})

if(WIN32)
    if(MSVC)
        set(PLATFORM_LIBRARIES Advapi32.lib)
    endif()
    if(GCC)
        set(PLATFORM_LIBRARIES advapi32)
    endif()
endif()

################################################################################

add_library(SingleApplication STATIC SingleApplication.cpp SingleApplication_private.cpp)

target_link_libraries(SingleApplication PRIVATE ${CORE_LIBRARIES} ${PLATFORM_LIBRARIES})
target_include_directories(SingleApplication PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_compile_definitions(SingleApplication PUBLIC QAPPLICATION_CLASS=${QAPPLICATION_CLASS})
target_compile_definitions(SingleApplication PRIVATE
    QT_NO_CAST_TO_ASCII
    QT_NO_CAST_FROM_ASCII
    QT_NO_URL_CAST_FROM_STRING
    QT_NO_CAST_FROM_BYTEARRAY
    QT_USE_QSTRINGBUILDER
    QT_NO_NARROWING_CONVERSIONS_IN_CONNECT
    QT_NO_KEYWORDS
    QT_NO_FOREACH
)
