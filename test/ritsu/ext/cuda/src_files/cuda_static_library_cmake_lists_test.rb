require File.dirname(__FILE__) + "/../../../../test_helpers"
require File.dirname(__FILE__) + "/../../../../../lib/ritsu/ext/cuda"

class CudaStaticLibraryCMakeListsTest < Test::Unit::TestCase
  include Ritsu::SetupProjectAndClearEverythingElse
  include Ritsu::TestCaseWithFileTestData
  include Ritsu::Utility
  
  def data_dir; File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".rb") end
  
  def setup
    setup_project('mio')
    @project.project_dir = output_dir
    @project.setup_cuda
  end
    
  file_test "must be present" do
    abc = Ritsu::Targets::StaticLibrary.new("abc", :project=>@project, :cuda_target=>true)
    abc.add_external_library "cuda"
    assert abc.respond_to?(:cmake_lists)
    assert abc.cmake_lists.kind_of?(Ritsu::SrcFiles::StaticLibraryCmakeLists)
    assert_equal 1,
     abc.src_files.select {|x| x.kind_of?(Ritsu::SrcFiles::StaticLibraryCmakeLists)}.length
  end
  
  file_test "create" do
    abc = Ritsu::Targets::StaticLibrary.new("abc", :project=>@project, :cuda_target=>true)
    FileRobot.quietly do
      abc.cmake_lists.create
    end
    assert_file_exists(abc.cmake_lists.abs_path)
    
    expected_content = <<-CMAKE
##<< TargetCmakeLists -- abc -- Libraries
##>> TargetCmakeLists -- abc -- Libraries

##<< TargetCmakeLists -- abc -- CudaIncludeDirectories
##>> TargetCmakeLists -- abc -- CudaIncludeDirectories

##<< TargetCmakeLists -- abc -- Custom Commands
##>> TargetCmakeLists -- abc -- Custom Commands

##<< TargetCmakeLists -- abc -- Source Files
SET(ABC_SRC_FILES
)
##>> TargetCmakeLists -- abc -- Source Files

##<< TargetCmakeLists -- abc -- CudaCompile
##>> TargetCmakeLists -- abc -- CudaCompile

##<< StaticLibraryCmakeLists -- abc -- Static Library
ADD_LIBRARY(abc STATIC ${ABC_SRC_FILES})
##>> StaticLibraryCmakeLists -- abc -- Static Library

##<< TargetCmakeLists -- abc -- Dependencies
##>> TargetCmakeLists -- abc -- Dependencies

##<< TargetCmakeLists -- abc -- Install
##>> TargetCmakeLists -- abc -- Install
CMAKE

    assert_file_content(expected_content, abc.cmake_lists.abs_path)
  end
end