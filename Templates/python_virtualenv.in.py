#!/usr/bin/env python
# This file contains information about installed virtual environments 

info = { dir: "@_OC_PYTHON_INSTALL_PREFIX@", toolchain: "@TOOLCHAIN@",
         mpi: "@OPENCMISS_MPI@", mpi_home: "@OPENCMISS_MPI_HOME@", buildtype: "@BTYPE@",
         compiler: "@COMPILER@", mpi_buildtype: "@OPENCMISS_MPI_BUILD_TYPE@",
         library_path: "@LIBRARY_PATH@", is_virtual_env: @IS_VIRTUALENV@, activate: "@ACTIVATE_SCRIPT@", }

if not virtualenvs:
    virtualenvs = []
virtualenvs.append(info)

