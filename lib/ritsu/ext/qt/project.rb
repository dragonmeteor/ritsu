require File.expand_path(File.dirname(__FILE__) + "/../../project")

module Ritsu
  class Project
    def setup_qt
      ### Qt ###
      add_external_library("qt") do |e|
        e.cmake_find_script <<-QT_FIND_SCRIPT

FIND_PACKAGE(Qt4 REQUIRED)

MACRO (RITSU_QT4_WRAP_UI outfiles )
  QT4_EXTRACT_OPTIONS(ui_files ui_options ${ARGN})

  FOREACH (it ${ui_files})
    GET_FILENAME_COMPONENT(outfile ${it} NAME_WE)
    GET_FILENAME_COMPONENT(infile ${it} ABSOLUTE)
    SET(outfile ${CMAKE_CURRENT_SOURCE_DIR}/ui_${outfile}.h)
    ADD_CUSTOM_COMMAND(OUTPUT ${outfile}
      COMMAND ${QT_UIC_EXECUTABLE}
      ARGS ${ui_options} -o ${outfile} ${infile}
      MAIN_DEPENDENCY ${infile})
    SET(${outfiles} ${${outfiles}} ${outfile})
  ENDFOREACH (it)

ENDMACRO (RITSU_QT4_WRAP_UI)

QT_FIND_SCRIPT
        e.cmake_depend_script "INCLUDE_DIRECTORIES(${QT_INCLUDE_DIR} ${QT_QTCORE_INCLUDE_DIR})"
        e.cmake_name "${QT_QTCORE_LIBRARY}"
      end

      ### Qt GUI ###
      add_external_library("qtgui") do |e|
        e.cmake_find_script ""
        e.cmake_depend_script "INCLUDE_DIRECTORIES(${QT_QTGUI_INCLUDE_DIR})"
        e.cmake_name "${QT_QTGUI_LIBRARY}"
      end

      ### Qt OpenGL ###
      add_external_library("qtopengl") do |e|
        e.cmake_find_script ""
        e.cmake_depend_script "INCLUDE_DIRECTORIES(${QT_QTOPENGL_INCLUDE_DIR})"
        e.cmake_name "${QT_QTOPENGL_LIBRARY}"
      end
    end
  end
end