require File.expand_path(File.dirname(__FILE__) + "/../../project")

module Ritsu
  class Project
    def setup_qt
      ### Qt ###
      add_external_library("qt") do |e|
        e.cmake_find_script "FIND_PACKAGE(Qt4 REQUIRED)"
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