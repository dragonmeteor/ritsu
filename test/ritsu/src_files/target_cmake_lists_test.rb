require File.dirname(__FILE__) + "/../../test_helpers"

class TargetCMakeListsTest < Test::Unit::TestCase
  include Ritsu::SetupProjectAndClearEverythingElse
  
  must "src_path must be target_name/CMakeLists.txt" do
    target = Ritsu::Targets::Executable.new("abc", :project=>@project)
    assert_equal "abc/CMakeLists.txt", target.cmake_lists.src_path
  end

  must "src_path must be project_dir/target_name/CMakeLists.txt" do
    target = Ritsu::Targets::Executable.new("abc", :project=>@project)
    assert_equal "#{@project.project_dir}/src/abc/CMakeLists.txt", 
      target.cmake_lists.abs_path
  end
end