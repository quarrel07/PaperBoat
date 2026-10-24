# Liquid Glass app icon from the Icon Composer file macosx/Paperboat.icon, shared by macOS and iOS.
# actool compiles it into Assets.car plus flat fallbacks for older OS versions. That needs Xcode 26+,
# so with an older Xcode (or no .icon) the result variable is FALSE and the caller keeps its PNG icon.
# The catalog icon is named after the file, so it must stay "Paperboat" to match CFBundleIconName.
set(PAPERBOAT_GLASS_ICON "${CMAKE_SOURCE_DIR}/macosx/Paperboat.icon")

# paperboat_compile_glass_icon(<out dir> <result var> <actool platform args...>)
function(paperboat_compile_glass_icon OUT_DIR OUT_VAR)
    set(${OUT_VAR} FALSE PARENT_SCOPE)
    if(NOT EXISTS "${PAPERBOAT_GLASS_ICON}")
        return()
    endif()
    file(GLOB_RECURSE icon_files "${PAPERBOAT_GLASS_ICON}/*")
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${icon_files})
    file(REMOVE_RECURSE "${OUT_DIR}")
    file(MAKE_DIRECTORY "${OUT_DIR}")
    execute_process(
        COMMAND xcrun actool "${PAPERBOAT_GLASS_ICON}" --compile "${OUT_DIR}" --app-icon Paperboat
                --output-partial-info-plist "${OUT_DIR}/partial.plist" ${ARGN} --errors --warnings
        RESULT_VARIABLE result OUTPUT_QUIET ERROR_QUIET
    )
    if(result EQUAL 0 AND EXISTS "${OUT_DIR}/Assets.car")
        set(${OUT_VAR} TRUE PARENT_SCOPE)
        message(STATUS "Liquid Glass app icon compiled from ${PAPERBOAT_GLASS_ICON}")
    else()
        message(STATUS "Liquid Glass app icon not compiled (actool needs Xcode 26+); using the PNG icon")
    endif()
endfunction()
