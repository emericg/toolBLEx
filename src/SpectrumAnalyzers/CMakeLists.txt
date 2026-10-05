################################################################################

target_sources(${PROJECT_NAME} PRIVATE
    SpectrumSource.cpp SpectrumSource.h
    SpectrumSourceUbertooth.cpp SpectrumSourceUbertooth.h
    SpectrumSourceRtlSdr.cpp SpectrumSourceRtlSdr.h
    SpectrumDriver.cpp SpectrumDriver.h

    WaterfallGraph_QuickItem.cpp WaterfallGraph_QuickItem.h
    SpectrumGraph3D_SurfaceHandler.cpp SpectrumGraph3D_SurfaceHandler.h
    PhosphorPersistenceGraph_QuickItem.cpp PhosphorPersistenceGraph_QuickItem.h
)

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

################################################################################

# Spectrum analyzers drivers
#   AUTO: library driver if found, binary driver otherwise (except on Windows)
#   LIB:  library driver, required
#   BIN:  binary driver (not supported on Windows)
#   OFF:  no driver, the spectrum analyzer is unavailable
set(TOOLBLEX_SPECTRUM_UBERTOOTH "AUTO" CACHE STRING "Ubertooth driver (AUTO, LIB, BIN, OFF)")
set(TOOLBLEX_SPECTRUM_RTLSDR "AUTO" CACHE STRING "RTL-SDR driver (AUTO, LIB, BIN, OFF)")
set_property(CACHE TOOLBLEX_SPECTRUM_UBERTOOTH PROPERTY STRINGS AUTO LIB BIN OFF)
set_property(CACHE TOOLBLEX_SPECTRUM_RTLSDR PROPERTY STRINGS AUTO LIB BIN OFF)

find_package(PkgConfig QUIET)

# toolblex_spectrum_driver(<device> <mode> <pkg-config module> <driver class prefix>)
function(toolblex_spectrum_driver DEVICE MODE PKG_MODULE DRIVER)
    string(TOUPPER ${DEVICE} DEV)
    set(driver "none")

    if(NOT MODE MATCHES "^(AUTO|LIB|BIN|OFF)$")
        message(FATAL_ERROR "TOOLBLEX_SPECTRUM_${DEV}: invalid value '${MODE}' (AUTO, LIB, BIN, OFF)")
    endif()

    if(MODE STREQUAL "AUTO" OR MODE STREQUAL "LIB")
        if(PkgConfig_FOUND)
            pkg_check_modules(${DEV}_LIB QUIET IMPORTED_TARGET GLOBAL ${PKG_MODULE})
        endif()
        if(${DEV}_LIB_FOUND)
            set(driver "LIB")
        elseif(MODE STREQUAL "LIB")
            message(FATAL_ERROR "TOOLBLEX_SPECTRUM_${DEV}=LIB but '${PKG_MODULE}' was not found")
        endif()
    endif()

    if(MODE STREQUAL "BIN" OR (MODE STREQUAL "AUTO" AND driver STREQUAL "none"))
        if(NOT WIN32)
            set(driver "BIN")
        elseif(MODE STREQUAL "BIN")
            message(FATAL_ERROR "TOOLBLEX_SPECTRUM_${DEV}=BIN is not supported on Windows")
        endif()
    endif()

    if(driver STREQUAL "LIB")
        target_sources(${PROJECT_NAME} PRIVATE
            SpectrumDriver_lib.cpp SpectrumDriver_lib.h
            ${DRIVER}_lib.cpp ${DRIVER}_lib.h)
        target_link_libraries(${PROJECT_NAME} PRIVATE PkgConfig::${DEV}_LIB)
        message(STATUS "[PROJECT] ${DEVICE} spectrum driver: library (${PKG_MODULE} ${${DEV}_LIB_VERSION})")
    elseif(driver STREQUAL "BIN")
        target_sources(${PROJECT_NAME} PRIVATE
            SpectrumDriver_bin.cpp SpectrumDriver_bin.h
            ${DRIVER}_bin.cpp ${DRIVER}_bin.h)
        message(STATUS "[PROJECT] ${DEVICE} spectrum driver: binaries")
    else()
        message(STATUS "[PROJECT] ${DEVICE} spectrum driver: none")
    endif()

    if(NOT driver STREQUAL "none")
        target_compile_definitions(${PROJECT_NAME} PRIVATE TOOLBLEX_${DEV}_${driver})
    endif()
endfunction()

toolblex_spectrum_driver(Ubertooth ${TOOLBLEX_SPECTRUM_UBERTOOTH} libusb-1.0 UbertoothDriver)
toolblex_spectrum_driver(RtlSdr ${TOOLBLEX_SPECTRUM_RTLSDR} librtlsdr RtlSdrDriver)

################################################################################
