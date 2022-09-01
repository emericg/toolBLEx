cmake_minimum_required(VERSION 3.12)

project(SingleApplication LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_AUTOMOC ON)

################################################################################

if(NOT QT_DEFAULT_MAJOR_VERSION)
    set(QT_DEFAULT_MAJOR_VERSION 6 CACHE STRING "Qt version to use (5 or 6), defaults to 6")
endif()

# Find dependencies
set(CORE_COMPONENTS Core Network)
set(CORE_LIBRARIES Qt::Core Qt::Network)

if(QAPPLICATION_CLASS STREQUAL QApplication)
    list(APPEND CORE_COMPONENTS Widgets)
    list(APPEND CORE_LIBRARIES Qt${QT_DEFAULT_MAJOR_VERSION}::Widgets)
elseif(QAPPLICATION_CLASS STREQUAL QGuiApplication)
    list(APPEND CORE_COMPONENTS Gui)
    list(APPEND CORE_LIBRARIES Qt${QT_DEFAULT_MAJOR_VERSION}::Gui)
else()
    set(QAPPLICATION_CLASS QCoreApplication)
endif()

find_package(Qt${QT_DEFAULT_MAJOR_VERSION} COMPONENTS ${CORE_COMPONENTS} REQUIRED)

if(WIN32)
    if(MSVC)
        set(PLATFORM_LIBRARIES Advapi32.lib)
    endif()
    if(GCC)
        set(PLATFORM_LIBRARIES advapi32)
    endif()
endif()

################################################################################

add_library(SingleApplication STATIC SingleApplication.cpp SingleApplication_private.cpp )
add_library(SingleApplication::SingleApplication ALIAS SingleApplication)

target_link_libraries(SingleApplication PUBLIC ${CORE_LIBRARIES} ${PLATFORM_LIBRARIES})
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
