################################################################################

target_sources(${PROJECT_NAME} PRIVATE
    AdapterDetails.h
    AdapterInfoUtils.h
    AdapterInfo.cpp AdapterInfo.h
)

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

################################################################################

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_sources(${PROJECT_NAME} PRIVATE
        AdapterInfoBluez.cpp AdapterInfoBluez.h
        BluezTypes.h
    )
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    target_sources(${PROJECT_NAME} PRIVATE
        AdapterInfoWindows.cpp AdapterInfoWindows.h
    )
    # WinRT (WindowsApp) is linked by the main CMakeLists.txt, Bthprops for the Win32 radio APIs
    target_link_libraries(${PROJECT_NAME} PRIVATE Bthprops)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    target_sources(${PROJECT_NAME} PRIVATE
        AdapterInfoMacos.cpp AdapterInfoMacos.h
    )
endif()

################################################################################
