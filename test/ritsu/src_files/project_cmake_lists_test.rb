require File.dirname(__FILE__) + "/../../test_helpers"

class ProjectCMakeListsTest < Test::Unit::TestCase
  include Ritsu::SetupProjectAndClearEverythingElse
  include Ritsu::TestCaseWithFileTestData
  include Ritsu::Utility
  
  def data_dir; File.expand_path(File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".rb")) end
  
  def setup
    setup_project('mio')
    @project.project_dir = output_dir
  end
  
  must "be present in project" do
    assert @project.respond_to?(:cmake_lists)
    assert @project.cmake_lists.kind_of?(Ritsu::SrcFiles::ProjectCmakeLists)
  end
  
  must "src_path must be CMakeLists.txt" do
    cmakelists = @project.cmake_lists
    assert_equal "CMakeLists.txt", cmakelists.src_path
  end
  
  must "abs_path must be project_dir/src/CMakeLists.txt" do
    cmakelists = @project.cmake_lists
    assert_equal "#{@project.project_dir}/src/CMakeLists.txt", 
      cmakelists.abs_path
  end
  
  file_test "create" do
    FileRobot.quietly do 
      @project.cmake_lists.create
    end
    assert_file_exists(@project.cmake_lists.abs_path)
    
    expected_content = <<-TEXT
##<< ProjectCmakeLists -- Header
PROJECT(mio)
CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake_modules" ${CMAKE_MODULE_PATH})

IF(WIN32)
    OPTION(__WIN_PLATFORM__ "Windows Platform" ON)
ELSE(WIN32)
    OPTION(__WIN_PLATFORM__ "Windows Platform" OFF)
ENDIF(WIN32)

IF(UNIX)
    IF(APPLE)
        OPTION(__MAC_PLATFORM__ "Apple Platform" ON)
        OPTION(__UNIX_PLATFORM__ "Unix Platform" OFF)
    ELSE(APPLE)
        OPTION(__MAC_PLATFORM__ "Apple Platform" OFF)
        OPTION(__UNIX_PLATFORM__ "Unix Platform" ON)
    ENDIF(APPLE)
ELSE(UNIX)
    OPTION(__MAC_PLATFORM__ "Apple Platform" OFF)
    OPTION(__UNIX_PLATFORM__ "Unix Platform" OFF)
ENDIF(UNIX)
##>> ProjectCmakeLists -- Header

##<< ProjectCmakeLists -- Custom Script

##>> ProjectCmakeLists -- Custom Script

##<< ProjectCmakeLists -- External Libraries
##>> ProjectCmakeLists -- External Libraries

##<< ProjectCmakeLists -- Directories
##>> ProjectCmakeLists -- Directories

##<< ProjectCmakeLists -- Configure File
CONFIGURE_FILE( ${CMAKE_SOURCE_DIR}/config.h.in ${CMAKE_SOURCE_DIR}/config.h )
##>> ProjectCmakeLists -- Configure File
TEXT
    
    assert_file_content(expected_content, @project.cmake_lists.abs_path)
  end
  
  file_test "create 2" do
    @project.add_external_library 'qt_core' do |e|
      e.cmake_name '${QT_LIBRARIES}'
      e.cmake_find_script <<-CMAKE
FIND_PACKAGE(Qt4 REQUIRED)
CMAKE
      e.cmake_depend_script <<-CMAKE
INCLUDE_DIRECTORIES(${QT_INCLUDE_DIR})
SET(QT_DONT_USE_QTGUI TRUE)
CMAKE
    end
    
    @project.add_external_library 'opengl' do |e|
      e.cmake_name '${OPENGL_LIBRARY}'
      e.cmake_find_script <<-CMAKE
FIND_PACKAGE(OpenGL REQUIRED)
CMAKE
      e.cmake_depend_script <<-CMAKE
INCLUDE_DIRECTORIES(${OPENGL_INCLUDE_DIR})
CMAKE
    end
    
    ghi = Ritsu::Targets::SharedLibrary.new("ghi", :project=>@project)
    abc = Ritsu::Targets::Executable.new("abc", :project=>@project)
    abc.dependency_targets << ghi
    
    FileRobot.quietly do
      @project.cmake_lists.create
    end

    expected_content = <<-TEXT
##<< ProjectCmakeLists -- Header
PROJECT(mio)
CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake_modules" ${CMAKE_MODULE_PATH})

IF(WIN32)
    OPTION(__WIN_PLATFORM__ "Windows Platform" ON)
ELSE(WIN32)
    OPTION(__WIN_PLATFORM__ "Windows Platform" OFF)
ENDIF(WIN32)

IF(UNIX)
    IF(APPLE)
        OPTION(__MAC_PLATFORM__ "Apple Platform" ON)
        OPTION(__UNIX_PLATFORM__ "Unix Platform" OFF)
    ELSE(APPLE)
        OPTION(__MAC_PLATFORM__ "Apple Platform" OFF)
        OPTION(__UNIX_PLATFORM__ "Unix Platform" ON)
    ENDIF(APPLE)
ELSE(UNIX)
    OPTION(__MAC_PLATFORM__ "Apple Platform" OFF)
    OPTION(__UNIX_PLATFORM__ "Unix Platform" OFF)
ENDIF(UNIX)
##>> ProjectCmakeLists -- Header

##<< ProjectCmakeLists -- Custom Script

##>> ProjectCmakeLists -- Custom Script

##<< ProjectCmakeLists -- External Libraries
FIND_PACKAGE(OpenGL REQUIRED)

FIND_PACKAGE(Qt4 REQUIRED)

##>> ProjectCmakeLists -- External Libraries

##<< ProjectCmakeLists -- Directories
ADD_SUBDIRECTORY(ghi)
ADD_SUBDIRECTORY(abc)
##>> ProjectCmakeLists -- Directories

##<< ProjectCmakeLists -- Configure File
CONFIGURE_FILE( ${CMAKE_SOURCE_DIR}/config.h.in ${CMAKE_SOURCE_DIR}/config.h )
##>> ProjectCmakeLists -- Configure File
TEXT

    assert_file_content(expected_content, @project.cmake_lists.abs_path)
  end
end