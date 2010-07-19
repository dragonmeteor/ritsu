require File.dirname(__FILE__) + "/../../test_helpers"

class SharedLibraryCMakeListsTest < Test::Unit::TestCase
  include Ritsu::SetupProjectAndClearEverythingElse
  include Ritsu::TestCaseWithFileTestData
  include Ritsu::Utility
  
  def data_dir; File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".rb") end
  
  def setup
    setup_project('mio')
    @project.project_dir = output_dir
  end
    
  file_test "must be present" do
    abc = Ritsu::Targets::SharedLibrary.new("abc", :project=>@project)
    assert abc.respond_to?(:cmake_lists)
    assert abc.cmake_lists.kind_of?(Ritsu::SrcFiles::SharedLibraryCmakeLists)
    assert_equal 1,
     abc.src_files.select {|x| x.kind_of?(Ritsu::SrcFiles::SharedLibraryCmakeLists)}.length
  end
  
  file_test "create" do
    abc = Ritsu::Targets::SharedLibrary.new("abc", :project=>@project)
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

##<< SharedLibraryCmakeLists -- abc -- Shared Library
ADD_LIBRARY(abc SHARED ${ABC_SRC_FILES})
##>> SharedLibraryCmakeLists -- abc -- Shared Library

##<< TargetCmakeLists -- abc -- Dependencies
##>> TargetCmakeLists -- abc -- Dependencies

##<< TargetCmakeLists -- abc -- Install
##>> TargetCmakeLists -- abc -- Install
CMAKE

    assert_file_content(expected_content, abc.cmake_lists.abs_path)
  end
end