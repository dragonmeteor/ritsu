require File.dirname(__FILE__) + "/../../test_helpers"

class ExecutableCMakeListsTest < Test::Unit::TestCase
  include Ritsu::SetupProjectAndClearEverythingElse
  include Ritsu::TestCaseWithFileTestData
  include Ritsu::Utility
  
  def data_dir; File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".rb") end
  
  def setup
    setup_project('mio')
    @project.project_dir = output_dir
  end
    
  file_test "must be present" do
    abc = Ritsu::Targets::Executable.new("abc", :project=>@project)
    assert abc.respond_to?(:cmake_lists)
    assert abc.cmake_lists.kind_of?(Ritsu::SrcFiles::ExecutableCmakeLists)
    assert_equal 1,
     abc.src_files.select {|x| x.kind_of?(Ritsu::SrcFiles::ExecutableCmakeLists)}.length
  end
  
  file_test "create" do
    abc = Ritsu::Targets::Executable.new("abc", :project=>@project)
    FileRobot.quietly do
      abc.cmake_lists.create
    end
    assert_file_exists(abc.cmake_lists.abs_path)
    
    expected_content = <<-CMAKE
##<< TargetCmakeLists -- abc -- Libraries
##>> TargetCmakeLists -- abc -- Libraries

##<< TargetCmakeLists -- abc -- Custom Commands
##>> TargetCmakeLists -- abc -- Custom Commands

##<< TargetCmakeLists -- abc -- Source Files
SET(ABC_SRC_FILES
)
##>> TargetCmakeLists -- abc -- Source Files

##<< ExecutableCmakeLists -- abc -- Executable
ADD_EXECUTABLE(abc ${ABC_SRC_FILES})
##>> ExecutableCmakeLists -- abc -- Executable

##<< TargetCmakeLists -- abc -- Dependencies
##>> TargetCmakeLists -- abc -- Dependencies

##<< TargetCmakeLists -- abc -- Install
##>> TargetCmakeLists -- abc -- Install
CMAKE

    assert_file_content(expected_content, abc.cmake_lists.abs_path)
  end
  
  file_test "install" do
    abc = Ritsu::Targets::Executable.new("abc", :project=>@project)
    abc.setup_install
    FileRobot.quietly do
      abc.cmake_lists.create
    end
    assert_file_exists(abc.cmake_lists.abs_path)

    expected_content = <<-CMAKE
##<< TargetCmakeLists -- abc -- Libraries
##>> TargetCmakeLists -- abc -- Libraries

##<< TargetCmakeLists -- abc -- Custom Commands
##>> TargetCmakeLists -- abc -- Custom Commands

##<< TargetCmakeLists -- abc -- Source Files
SET(ABC_SRC_FILES
)
##>> TargetCmakeLists -- abc -- Source Files

##<< ExecutableCmakeLists -- abc -- Executable
ADD_EXECUTABLE(abc ${ABC_SRC_FILES})
##>> ExecutableCmakeLists -- abc -- Executable

##<< TargetCmakeLists -- abc -- Dependencies
##>> TargetCmakeLists -- abc -- Dependencies

##<< TargetCmakeLists -- abc -- Install
INSTALL(TARGETS abc
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
)
##>> TargetCmakeLists -- abc -- Install
CMAKE

    assert_file_content(expected_content, abc.cmake_lists.abs_path)
  end
end