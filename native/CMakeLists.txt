cmake_minimum_required(VERSION 3.24)
project(fa_native LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(NOT WIN32)
  message(FATAL_ERROR "only the Windows platform layer exists so far")
endif()
if(NOT MSVC)
  message(FATAL_ERROR "the Windows build must use MSVC: the DLL calls into factorio.exe's MSVC ABI")
endif()
# Static CRT: players should not need a particular VC++ redistributable.
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
add_compile_definitions(WIN32_LEAN_AND_MEAN NOMINMAX _CRT_SECURE_NO_WARNINGS UNICODE _UNICODE)
# /EHsc matters beyond style: Factorio's Lua raises errors as C++ exceptions, which unwind through our frames.
add_compile_options(/utf-8 /W4 /permissive- /Zc:__cplusplus /EHsc)

# --- Microsoft Detours (vendored source) ---
set(DETOURS_SRC ${CMAKE_SOURCE_DIR}/third_party/Detours/src)
add_library(detours STATIC
  ${DETOURS_SRC}/detours.cpp ${DETOURS_SRC}/modules.cpp ${DETOURS_SRC}/disasm.cpp
  ${DETOURS_SRC}/image.cpp ${DETOURS_SRC}/creatwth.cpp)
target_include_directories(detours PUBLIC ${DETOURS_SRC})
target_compile_options(detours PRIVATE /W0)

# --- prism speech (prebuilt; delay-loaded from next to fa_native.dll) ---
set(PRISM_DIR ${CMAKE_SOURCE_DIR}/third_party/prism)
set(PRISM_LIB ${PRISM_DIR}/windows/x64/lib/prism.lib)
set(PRISM_DLL ${PRISM_DIR}/windows/x64/bin/prism.dll)

# --- engine-free UI core: navigation graph, screens, input, message building (no Windows, no game types) ---
file(GLOB FAUI_SOURCES CONFIGURE_DEPENDS src/ui/*.cpp)
add_library(faui STATIC ${FAUI_SOURCES})
target_include_directories(faui PUBLIC src)

# --- the update check's decisions (engine-free; the WinHTTP side is src/win/update_check.cpp) ---
add_library(fa_update STATIC src/update/check.cpp)
target_link_libraries(fa_update PUBLIC faui)

file(GLOB FAUI_TESTS CONFIGURE_DEPENDS tests/*.cpp)
add_executable(faui_tests ${FAUI_TESTS})
target_include_directories(faui_tests PRIVATE third_party)
target_link_libraries(faui_tests PRIVATE faui fa_update)

# --- the native code's own version, embedded at configure time ---
# CI sets FA_VERSION (a tag "v0.16.57" or "ci-<short sha>") before configuring; a local build is "dev" (the update
# check stays silent). The same string goes to version.txt, which the native release zip carries for the installer.
# Changing it needs a reconfigure.
if(DEFINED ENV{FA_VERSION} AND NOT "$ENV{FA_VERSION}" STREQUAL "")
  set(FA_VERSION "$ENV{FA_VERSION}")
else()
  set(FA_VERSION "dev")
endif()
message(STATUS "fa_native version: ${FA_VERSION}")
configure_file(src/fa_version.h.in ${CMAKE_BINARY_DIR}/generated/fa_version.h @ONLY)
file(WRITE ${CMAKE_BINARY_DIR}/version.txt "${FA_VERSION}
")

# --- the injected DLL ---
add_library(fa_native SHARED
  src/dllmain.cpp src/log.cpp src/input.cpp src/app.cpp src/assets.cpp src/lua_native.cpp src/screens/dialogs.cpp src/win/game.cpp src/win/audio_mute.cpp src/speech.cpp src/devserver.cpp
  src/win/hooks.cpp src/win/sym.cpp src/win/window.cpp src/win/agui.cpp src/win/update_check.cpp src/win/watchdog.cpp)
target_include_directories(fa_native PRIVATE src ${PRISM_DIR}/include ${CMAKE_BINARY_DIR}/generated)
target_link_libraries(fa_native PRIVATE faui fa_update fa_audio detours ${PRISM_LIB} user32 ws2_32 ole32 dbghelp delayimp winhttp)
target_link_options(fa_native PRIVATE /DELAYLOAD:prism.dll)
add_custom_command(TARGET fa_native POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${PRISM_DLL} $<TARGET_FILE_DIR:fa_native>)

# --- the dev injector (launch suspended + inject, eject) ---
add_executable(fa_inject src/inject/main.cpp)
target_link_libraries(fa_inject PRIVATE psapi)

# --- audio: the launcher's fa_launcher_audio ported in-process (miniaudio + JSON commands from the mod) ---
set(MINIAUDIO_DIR ${CMAKE_SOURCE_DIR}/third_party/miniaudio)
add_library(fa_audio STATIC
  src/audio/audio.cpp src/audio/commands.cpp src/audio/json.cpp src/audio/panner_node.c src/audio/miniaudio_impl.c)
target_include_directories(fa_audio PUBLIC src PRIVATE ${MINIAUDIO_DIR})
add_executable(fa_audio_tests tests_audio/main.cpp tests_audio/commands_tests.cpp tests_audio/params_tests.cpp tests_audio/json_tests.cpp
  tests_audio/engine_tests.cpp)
target_include_directories(fa_audio_tests PRIVATE third_party)
target_link_libraries(fa_audio_tests PRIVATE fa_audio)

# --- version.dll: the proxy factorio.exe loads from its own folder (fadev.py install puts it there) ---
add_library(version_proxy SHARED src/proxy/version.cpp)
set_target_properties(version_proxy PROPERTIES OUTPUT_NAME version)
