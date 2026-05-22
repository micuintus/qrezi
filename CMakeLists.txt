cmake_minimum_required(VERSION 3.18)

project(Qrezi LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

if (QT_KNOWN_POLICY_QTP0001)
    qt6_policy(SET QTP0001 NEW)
endif()

# =============================================================================
# Qrezi base module
# =============================================================================

file(GLOB qrezi_qml_files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS modules/Qrezi/*.qml)
file(GLOB qrezi_js_files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS
    modules/Qrezi/*.js
    modules/Qrezi/hljs/*.js
    modules/Qrezi/hljs/languages/*.js
)

qt6_add_qml_module(Qrezi
    URI Qrezi
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/Qrezi
    NO_PLUGIN
    QML_FILES ${qrezi_qml_files}
    RESOURCES ${qrezi_js_files}
)

# =============================================================================
# StructuredSlides module
# =============================================================================

file(GLOB structuredslides_qml_files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS modules/StructuredSlides/*.qml)

qt6_add_qml_module(StructuredSlides
    URI StructuredSlides
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/StructuredSlides
    NO_PLUGIN
    QML_FILES ${structuredslides_qml_files}
)

target_link_libraries(StructuredSlides PRIVATE Qrezi)
