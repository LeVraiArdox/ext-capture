cmake_minimum_required(VERSION 3.22)
project(ExtCapture VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick)
find_package(Qt6 REQUIRED COMPONENTS GuiPrivate)
find_package(PkgConfig REQUIRED)

pkg_check_modules(WAYLAND_CLIENT  REQUIRED IMPORTED_TARGET wayland-client)
pkg_check_modules(WAYLAND_PROTOS  REQUIRED IMPORTED_TARGET wayland-protocols)
pkg_check_modules(GBM             REQUIRED IMPORTED_TARGET gbm)
pkg_check_modules(DRM             REQUIRED IMPORTED_TARGET libdrm)
pkg_check_modules(EGL             REQUIRED IMPORTED_TARGET egl)
pkg_check_modules(GLESv2          REQUIRED IMPORTED_TARGET glesv2)

find_program(WAYLAND_SCANNER wayland-scanner REQUIRED)

# Locate the system protocol XMLs
pkg_get_variable(WL_PROTO_DIR wayland-protocols pkgdatadir)

set(PROTO_DIR "${CMAKE_SOURCE_DIR}/protocols")

macro(wayland_add_protocol _target _xml _kind)
    get_filename_component(_base "${_xml}" NAME_WE)
    set(_header  "${CMAKE_CURRENT_BINARY_DIR}/${_base}-client-protocol.h")
    set(_source  "${CMAKE_CURRENT_BINARY_DIR}/${_base}-client-protocol.c")

    add_custom_command(
        OUTPUT "${_header}"
        COMMAND "${WAYLAND_SCANNER}" client-header "${_xml}" "${_header}"
        DEPENDS "${_xml}"
        VERBATIM
    )
    add_custom_command(
        OUTPUT "${_source}"
        COMMAND "${WAYLAND_SCANNER}" private-code "${_xml}" "${_source}"
        DEPENDS "${_xml}"
        VERBATIM
    )
    target_sources(${_target} PRIVATE "${_header}" "${_source}")
    target_include_directories(${_target} PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
endmacro()

qt_add_library(ExtCapturePlugin SHARED)

qt_add_qml_module(ExtCapturePlugin
    URI "Sleex.ExtCapture"
    VERSION 1.0
    SOURCES
        src/ExtCaptureItem.h
        src/ExtCaptureItem.cpp
        src/GbmBuffer.h
        src/GbmBuffer.cpp
        src/plugin.cpp
)

# System staging protocols:
#   ${WL_PROTO_DIR}/staging/ext-image-copy-capture/ext-image-copy-capture-v1.xml
#   ${WL_PROTO_DIR}/staging/ext-foreign-toplevel-list/ext-foreign-toplevel-list-v1.xml
# Unstable:
#   ${WL_PROTO_DIR}/unstable/linux-dmabuf/linux-dmabuf-unstable-v1.xml
wayland_add_protocol(ExtCapturePlugin
    "${WL_PROTO_DIR}/staging/ext-image-copy-capture/ext-image-copy-capture-v1.xml" client)

wayland_add_protocol(ExtCapturePlugin
    "${WL_PROTO_DIR}/staging/ext-image-capture-source/ext-image-capture-source-v1.xml" client)

wayland_add_protocol(ExtCapturePlugin
    "${WL_PROTO_DIR}/staging/ext-foreign-toplevel-list/ext-foreign-toplevel-list-v1.xml" client)

wayland_add_protocol(ExtCapturePlugin
    "${WL_PROTO_DIR}/unstable/linux-dmabuf/linux-dmabuf-unstable-v1.xml" client)

target_include_directories(ExtCapturePlugin
    PRIVATE src "${CMAKE_CURRENT_BINARY_DIR}"
)

target_link_libraries(ExtCapturePlugin
    PRIVATE
        Qt6::Core Qt6::Gui Qt6::GuiPrivate Qt6::Quick
        PkgConfig::WAYLAND_CLIENT
        PkgConfig::GBM
        PkgConfig::DRM
        PkgConfig::EGL
        PkgConfig::GLESv2
)

qt_add_executable(ext-capture-demo
    src/main_demo.cpp
)
qt_add_qml_module(ext-capture-demo
    URI "DemoApp"
    VERSION 1.0
    QML_FILES qml/Demo.qml
)
target_link_libraries(ext-capture-demo PRIVATE Qt6::Core Qt6::Gui Qt6::Quick ExtCapturePlugin)