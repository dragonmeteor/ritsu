require File.dirname(__FILE__) + "/../../test_helpers"

class HeaderFileTest < Test::Unit::TestCase
  include Ritsu::SetupProjectAndClearEverythingElse
  include Ritsu::TestCaseWithFileTestData
  include Ritsu::Utility
  
  def setup
    setup_project
    @project.project_dir = output_dir
    @target = Ritsu::Targets::Executable.new("abc", :project=>@project)
  end
  
  def data_dir; File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".rb") end
  
  must "include_guard computed correct" do
    @header_file = Ritsu::SrcFiles::HeaderFile.new("abc/def.h", @target)
    assert_equal "__PROJECT_ABC_DEF_H__", @header_file.include_guard
  end
  
  file_test "create" do
    @header_file = Ritsu::SrcFiles::HeaderFile.new("abc/def.h", @target)
    FileRobot.quietly do
      @header_file.create
    end
    assert_file_exists(@header_file.abs_path)
    expected_content = <<-HEADER_FILE
#ifndef __PROJECT_ABC_DEF_H__
#define __PROJECT_ABC_DEF_H__

////////////////////
// YOUR CODE HERE //
////////////////////

#endif
HEADER_FILE
    assert_file_content(expected_content, @header_file.abs_path)
  end
  
  file_test "update_does_nothing" do
    @header_file = Ritsu::SrcFiles::HeaderFile.new("abc/def.h", @target)
    FileRobot.quietly do
      FileRobot.create_file(output_path("src/abc/def.h"), "abc")
      @header_file.update
    end
    assert_file_content("abc", @header_file.abs_path)
  end
  
  file_test "delete" do
    @header_file = Ritsu::SrcFiles::HeaderFile.new("abc/def.h", @target)
    FileRobot.quietly do
      @header_file.create
      assert_file_exists(@header_file.abs_path)
      @header_file.remove
      assert_file_not_exist(@header_file.abs_path)
    end
  end
end