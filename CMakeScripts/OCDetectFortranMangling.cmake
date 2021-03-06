# Fortran mangling - only detect if not already set manually.
if (NOT FORTRAN_MANGLING)
    include(FortranCInterface)
    log("Detected Fortran mangling: Suffix '${FortranCInterface_GLOBAL_SUFFIX}', Case '${FortranCInterface_GLOBAL_CASE}'")
    FortranCInterface_VERIFY()
    FortranCInterface_VERIFY(CXX)
    if (FortranCInterface_GLOBAL_SUFFIX STREQUAL _ AND FortranCInterface_GLOBAL_CASE STREQUAL LOWER)
        SET(FORTRAN_MANGLING Add_)
    elseif(FortranCInterface_GLOBAL_SUFFIX STREQUAL "" AND FortranCInterface_GLOBAL_CASE STREQUAL UPPER)
        SET(FORTRAN_MANGLING UpCase)
    elseif(FortranCInterface_GLOBAL_SUFFIX STREQUAL "" AND FortranCInterface_GLOBAL_CASE STREQUAL "")
        SET(FORTRAN_MANGLING NO)    
    endif()
    if (NOT FORTRAN_MANGLING)
        log("Fortran mangling autodetection: case not implemented yet: Suffix '${FortranCInterface_GLOBAL_SUFFIX}', Case '${FortranCInterface_GLOBAL_CASE}'" WARNING)
    endif()
endif()
