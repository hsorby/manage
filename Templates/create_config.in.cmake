if (NOT EXISTS "${CONFIG_PATH}")
    make_directory("${CONFIG_PATH}")
endif ()

if (EXISTS "${CMAKE_CURRENT_BINARY_DIR}/config")
    set(_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/config")
elseif (EXISTS "${CMAKE_CURRENT_BINARY_DIR}/configs")
    set(_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/configs")
endif ()

file(GLOB _RESULT ${_CONFIG_DIR})
list(LENGTH _RESULT _RES_LEN)
message(STATUS "_RESULT: ${_RESULT}")
message(STATUS "_RES_LEN: ${_RES_LEN}")
if (_RES_LEN EQUAL 0)
    set(_CONFIG_FINALISED FALSE)
else ()
    set(_CONFIG_FINALISED TRUE)
endif ()

if (EXISTS "${CMAKE_CURRENT_BINARY_DIR}/config")
    message(STATUS "::::: EXISTS")
endif ()

execute_process(
    COMMAND "${CMAKE_COMMAND}" -E remove "${DOLLAR_SYMBOL}{STAMP_FILE}"
    COMMAND "${CMAKE_COMMAND}" -E remove "${DOLLAR_SYMBOL}{BUILD_STAMP_FILE}"
    COMMAND "${CMAKE_COMMAND}" -G "${CMAKE_GENERATOR}" ${CONFIGURATION_SETTINGS} "${CMAKE_CURRENT_SOURCE_DIR}/LibrariesConfig"
    WORKING_DIRECTORY "${CONFIG_PATH}"
    RESULT_VARIABLE RESULT
)


if ("${DOLLAR_SYMBOL}{RESULT}" STREQUAL "0")
    if (EXISTS "${CMAKE_CURRENT_BINARY_DIR}/config")
        message(STATUS "::::: EXISTS NOW")
    endif ()
    
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CONFIG_PATH}/stamp"
        COMMAND "${CMAKE_COMMAND}" -E touch "${DOLLAR_SYMBOL}{STAMP_FILE}"
    )
    if (NOT _CONFIG_FINALISED)
        message(STATUS "Finalising configuration.")
        execute_process(
            COMMAND "${CMAKE_COMMAND}" .
            WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        )
    endif ()
    set(RESULT_MESSAGE "Configuration successful: ${CONFIG_PATH}")
else ()
    set(RESULT_MESSAGE "Failed to create configuration")
    message(SEND_ERROR "${RESULT_MESSAGE}")
endif ()

message(STATUS "@")
message(STATUS "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
message(STATUS "@")
message(STATUS "@ ${DOLLAR_SYMBOL}{RESULT_MESSAGE}")
message(STATUS "@")
message(STATUS "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
message(STATUS "@")
