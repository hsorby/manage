########################################################################
# These values will be put in place at generation phase.
# They could've also been passed over as command line definitions, however,
# this would allow to mess with them later. As this is the top level CMakeLists.txt
# for this specific compiler/mpi choice and sub-external projects rely on this
# choice, it's hard-coded rather than being modifiable (externally).
SET(OPENCMISS_ROOT @OPENCMISS_ROOT@)
SET(OPENCMISS_MANAGE_DIR @OPENCMISS_MANAGE_DIR@)
@TOOLCHAIN_DEF@
SET(MPI @MPI@)
SET(OCM_SYSTEM_MPI @SYSTEM_MPI@)
@MPI_HOME_DEF@
########################################################################

# Set up include path
LIST(APPEND CMAKE_MODULE_PATH
    ${OPENCMISS_MANAGE_DIR}
    ${OPENCMISS_MANAGE_DIR}/CMakeFindModuleWrappers
    ${OPENCMISS_MANAGE_DIR}/CMakeModules
    ${OPENCMISS_MANAGE_DIR}/CMakeScripts
    ${OPENCMISS_MANAGE_DIR}/Config)

# This includes the configuration, both default and local
include(OpenCMISSConfig)

# Between reading the config and starting the setup project.. this is the time for compiler stuff!
include(ToolchainSetup)

########################################################################
# Ready to start the "build project"
CMAKE_MINIMUM_REQUIRED(VERSION 3.2.0-rc1 FATAL_ERROR)
project(OpenCMISS-Build VERSION 1.0 LANGUAGES C CXX Fortran)
if ((NOT WIN32 OR MINGW) AND CMAKE_BUILD_TYPE STREQUAL "")
    SET(CMAKE_BUILD_TYPE RELEASE)
    message(STATUS "No CMAKE_BUILD_TYPE has been defined. Using RELEASE.")
endif()

include(ExternalProject)
include(OCMSetupArchitecture)
include(OCMSetupBuildMacros)

########################################################################
# Utilities (Wrappers, Fortran interface ...)
include(Utilities)

# Multithreading
if(OCM_USE_MT)
    find_package(OpenMP REQUIRED)
endif()

########################################################################
# MPI

# Unless we said to not have MPI or MPI_HOME is given, see that it's available.
if(NOT (DEFINED MPI_HOME OR MPI STREQUAL none))
    include(MPIConfig)
endif()
# Note:
# If MPI_HOME is set, we'll just pass it on to the external projects where the
# FindMPI.cmake module is going to look exclusively there.
# The availability of an MPI implementation at MPI_HOME was made sure
# in the MPIPreflight.cmake script upon generation time of this script.

# Checks for known issues as good as possible
# TODO: move this to the generator script (suitably)!
if (CMAKE_COMPILER_IS_GNUC AND MPI STREQUAL intel)
    message(FATAL_ERROR "Invalid compiler/MPI combination: Cannot build with GNU compiler and Intel MPI.")
endif()

########################################################################
# General paths & preps
get_architecture_path(ARCHITECTURE_PATH)
# Build tree location for components
SET(OPENCMISS_COMPONENTS_BINARY_DIR ${OPENCMISS_ROOT}/build/${ARCHITECTURE_PATH})
# Install dir
# Extra path segment for single configuration case - will give release/debug/...
get_build_type_extra(BUILDTYPEEXTRA)
# everything from the OpenCMISS main project goes into install/
SET(OPENCMISS_COMPONENTS_INSTALL_PREFIX ${OPENCMISS_ROOT}/install/${ARCHITECTURE_PATH}/${BUILDTYPEEXTRA})
# Misc definitions
# The COMMON_PACKAGE_CONFIG_DIR contains the cmake-generated target config files consumed by find_package(... CONFIG).
# Those are "usually" placed under the lib/ folders of the installation tree, however, the OpenCMISS build system
# install trees also have the build type as subfolders. As the config-files generated natively create differently named files
# for each build type, they can be collected in a common subfolder. As the build type subfolder-element is the last in line,
# we simply use the parent folder of the component's CMAKE_INSTALL_PREFIX to place the cmake package config files.
SET(COMMON_PACKAGE_CONFIG_DIR cmake) #../cmake ${OPENCMISS_ROOT}/install/${ARCHITECTURE_PATH}/

# build/x86/gnu/mpi/mpich/release
# build/x86/gnu/mpi/mpich/debug
# build/x86/gnu/mpich/static/release
# build/x86/gnu/no_mpi/static/release
# install/x86/gnu/mpi/mpich/release
# install/x86/gnu/mpi/mpich/debug
# install/x86/gnu/mpi/mpich/profile
# install/x86/gnu/mpi/openmpi

# install/x86/gnu/mpich/static/hypre/release/lib
# install/x86/gnu/mpich/static/hypre/debug/lib
# install/x86/gnu/mpich/static/hypre/profile/lib
# install/x86/gnu/mpich/shared/hypre/debug/lib
# install/x86/gnu/openmpi/static/hypre/release/lib
# install/x86/gnu/no_mpi/static/zlib/release/lib
# install/x86/gnu/no_mpi/static/cmake
# install/x86/gnu/mpich/shared/cmake

# The path where find_package calls will find the cmake package config files
set(OPENCMISS_PREFIX_PATH ${OPENCMISS_COMPONENTS_INSTALL_PREFIX}/${COMMON_PACKAGE_CONFIG_DIR})

# Collect the common arguments for any package/component
include(CollectComponentDefinitions)

#message(STATUS "OpenCMISS components common definitions:\n${COMPONENT_COMMON_DEFS}")

# Those list variables will be filled by the build macros
SET(_OCM_REQUIRED_SOURCES )
SET(_OCM_NEED_INITIAL_SOURCE_DOWNLOAD NO)

########################################################################
# Actual external project configurations

# Dependencies, Iron, ...
include(ConfigureComponents)

# Examples
include(AddExamplesProject)

########################################################################
# Export the currently applied configuration for consumation by
include(ExportBuildContext)

########################################################################
# Misc targets for convenience
# update: Updates the whole source tree
# reset:

# Create a download target that depends on all other downloads
SET(_OCM_SOURCE_UPDATE_TARGETS )
#SET(_OCM_SOURCE_DOWNLOAD_TARGETS )
foreach(_COMP ${_OCM_REQUIRED_SOURCES})
    LIST(APPEND _OCM_SOURCE_UPDATE_TARGETS ${_COMP}_SRC-update)
    #LIST(APPEND _OCM_SOURCE_DOWNLOAD_TARGETS ${_COMP}_SRC-download)
endforeach()
add_custom_target(update
    DEPENDS ${_OCM_SOURCE_UPDATE_TARGETS}
)
# I already foresee that we will have to have "download" and "update" targets for the less insighted user.
# So lets just give it to them. Does the same as external project has initial download and update steps.
#add_custom_target(download
#    DEPENDS ${_OCM_SOURCE_DOWNLOAD_TARGETS}
#)
# Note: Added a <COMP>-SRC project that takes care to have the sources ready