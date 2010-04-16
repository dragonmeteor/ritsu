require File.dirname(__FILE__) + "/../../test_helpers"

class CppFileTest < Test::Unit::TestCase
  include SetupProjectAndClearEverythingElse
  include TestCaseWithFileTestData
  include Ritsu::Utility
  
  def data_dir; File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".rb") end
  
  def setup
    setup_project
    @project.project_dir = output_dir
    @target = Ritsu::Targets::Executable.new("abc", :project=>@project)
  end
  
  file_test "create" do
    @header_file = Ritsu::SrcFiles::CppFile.new("abc/def.cpp", @target)
    FileRobot.quietly do
      @header_file.create
    end
    assert_file_exists(@header_file.abs_path)
    assert_file_content("", @header_file.abs_path)
  end

  file_test "update_does_nothing" do
    @header_file = Ritsu::SrcFiles::CppFile.new("abc/def.cpp", @target)
    FileRobot.quietly do
      FileRobot.create_file(output_path("src/abc/def.cpp"), "abc")
      @header_file.update
    end
    assert_file_content("abc", @header_file.abs_path)
  end

  file_test "delete" do
    @header_file = Ritsu::SrcFiles::CppFile.new("abc/def.cpp", @target)
    FileRobot.quietly do
      @header_file.create
      assert_file_exists(@header_file.abs_path)
      @header_file.remove
      assert_file_not_exist(@header_file.abs_path)
    end
  end
end