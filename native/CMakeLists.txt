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

# --- the injected DLL ---
add_library(fa_native SHARED
  src/dllmain.cpp src/log.cpp src/speech.cpp src/devserver.cpp
  src/win/hooks.cpp src/win/sym.cpp src/win/window.cpp src/win/agui.cpp)
target_include_directories(fa_native PRIVATE src ${PRISM_DIR}/include)
target_link_libraries(fa_native PRIVATE detours ${PRISM_LIB} user32 ws2_32 dbghelp delayimp)
target_link_options(fa_native PRIVATE /DELAYLOAD:prism.dll)
add_custom_command(TARGET fa_native POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${PRISM_DLL} $<TARGET_FILE_DIR:fa_native>)

# --- the dev injector (launch suspended + inject, eject) ---
add_executable(fa_inject src/inject/main.cpp)
target_link_libraries(fa_inject PRIVATE psapi)
