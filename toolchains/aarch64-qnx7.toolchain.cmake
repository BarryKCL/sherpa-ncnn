# QNX 7.x aarch64 — GCC/g++ toolchain for ncnn (Windows host)

# --- Target triple ---
set(CMAKE_SYSTEM_NAME QNX)
set(CMAKE_SYSTEM_VERSION 7)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# --- Environment check ---
if(NOT DEFINED ENV{QNX_HOST})
  message(FATAL_ERROR "QNX_HOST not set. Open CMD and call qnxsdp-env.bat first.")
endif()
if(NOT DEFINED ENV{QNX_TARGET})
  message(FATAL_ERROR "QNX_TARGET not set. Open CMD and call qnxsdp-env.bat first.")
endif()

# Normalize for Windows paths
set(QNX_HOST   "$ENV{QNX_HOST}")
set(QNX_TARGET "$ENV{QNX_TARGET}")
message(STATUS "using QNX_HOST ${QNX_HOST}")
message(STATUS "using QNX_TARGET ${QNX_TARGET}")

# --- Compilers (prefer CC/CXX env, else find QNX7 names) ---
if(DEFINED ENV{CC})
  file(TO_CMAKE_PATH "$ENV{CC}"  CMAKE_C_COMPILER)
endif()
if(DEFINED ENV{CXX})
  file(TO_CMAKE_PATH "$ENV{CXX}" CMAKE_CXX_COMPILER)
endif()

if(NOT CMAKE_C_COMPILER)
  find_program(CMAKE_C_COMPILER
    NAMES aarch64-unknown-nto-qnx7.1.0-gcc-8.3.0.exe aarch64-unknown-nto-qnx7.1.0-gcc.exe
    PATHS "${QNX_HOST}/usr/bin" NO_DEFAULT_PATH REQUIRED)
endif()
if(NOT CMAKE_CXX_COMPILER)
  find_program(CMAKE_CXX_COMPILER
    NAMES aarch64-unknown-nto-qnx7.1.0-g++-8.3.0.exe aarch64-unknown-nto-qnx7.1.0-g++.exe
    PATHS "${QNX_HOST}/usr/bin" NO_DEFAULT_PATH REQUIRED)
endif()

# Optional binutils (not strictly required)
find_program(CMAKE_AR     aarch64-unknown-nto-qnx7.1.0-ar.exe     PATHS "${QNX_HOST}/usr/bin" NO_DEFAULT_PATH)
find_program(CMAKE_RANLIB aarch64-unknown-nto-qnx7.1.0-ranlib.exe PATHS "${QNX_HOST}/usr/bin" NO_DEFAULT_PATH)
find_program(CMAKE_STRIP  aarch64-unknown-nto-qnx7.1.0-strip.exe  PATHS "${QNX_HOST}/usr/bin" NO_DEFAULT_PATH)

# --- Sysroot & search modes (QNX7: headers at $QNX_TARGET/usr/include; libs at $QNX_TARGET/aarch64le/usr/lib) ---
set(CMAKE_SYSROOT "${QNX_TARGET}")
set(CMAKE_FIND_ROOT_PATH "${QNX_TARGET}" "${QNX_TARGET}/aarch64le")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -latomic")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -latomic")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -latomic")

# Cross: never try-run
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# --- Default flags (inject sysroot + sane defaults) ---
# OpenMP 在 QNX7 上通常缺 libgomp；如需开启请在顶层 -DNCNN_OPENMP=ON 且准备好 gomp
string(APPEND CMAKE_C_FLAGS_INIT
  " --sysroot=${CMAKE_SYSROOT} -fPIC -O2 -Wall -Wextra -D_QNX_SOURCE -D_POSIX_C_SOURCE=200809L")
string(APPEND CMAKE_CXX_FLAGS_INIT
  " --sysroot=${CMAKE_SYSROOT} -fPIC -O2 -Wall -Wextra -std=c++17 -D_QNX_SOURCE -D_POSIX_C_SOURCE=200809L")
string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT
  " --sysroot=${CMAKE_SYSROOT}")
string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT
  " --sysroot=${CMAKE_SYSROOT}")
