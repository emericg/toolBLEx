cmake_minimum_required(VERSION 3.20)

#project(SingleApplication LANGUAGES CXX)

# To avoid CMake Warnings, you should add Qt6 'Widgets' or 'Gui', as needed,
# to your root level find_package()

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

################################################################################

if(NOT QAPPLICATION_CLASS)
    if(IOS OR ANDROID)
        message(STATUS "SingleApplication > QAPPLICATION_CLASS is not set, using default for mobile: QGuiApplication")
        set(QAPPLICATION_CLASS QGuiApplication)
    else()
        message(STATUS "SingleApplication > QAPPLICATION_CLASS is not set, using default for desktop: QApplication")
        set(QAPPLICATION_CLASS QApplication)
    endif()
endif()

################################################################################

# Generic dependencies
set(CORE_COMPONENTS Core Network)
set(CORE_LIBRARIES Qt6::Core Qt6::Network)

if(QAPPLICATION_CLASS STREQUAL QApplication)
    list(APPEND CORE_COMPONENTS Widgets)
    list(APPEND CORE_LIBRARIES Qt6::Widgets)
elseif(QAPPLICATION_CLASS STREQUAL QGuiApplication)
    list(APPEND CORE_COMPONENTS Gui)
    list(APPEND CORE_LIBRARIES Qt6::Gui)
endif()

# OS specific sources & dependencies
if(WIN32)
    if(MSVC)
        set(PLATFORM_LIBRARIES Advapi32.lib)
    else()
        set(PLATFORM_LIBRARIES advapi32)
    endif()
endif()

################################################################################

find_package(Qt6 6.5 REQUIRED COMPONENTS ${CORE_COMPONENTS})

add_library(SingleApplication STATIC SingleApplication.cpp SingleApplication_private.cpp)
add_library(SingleApplication::SingleApplication ALIAS SingleApplication)

target_link_libraries(SingleApplication PUBLIC ${CORE_LIBRARIES})
target_link_libraries(SingleApplication PRIVATE ${PLATFORM_LIBRARIES})

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

################################################################################
