make_directory(${CONFIG_PATH})
execute_process(
    COMMAND "${CMAKE_COMMAND}" ${CURRENT_CONFIGURATION_ARGS} "${CMAKE_CURRENT_SOURCE_DIR}/config"
    WORKING_DIRECTORY ${CONFIG_PATH}
    )
