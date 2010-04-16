require File.dirname(__FILE__) + "/../test_helpers"

class SrcFileTest < Test::Unit::TestCase
  include SetupProjectAndClearEverythingElse
  
  def self.test_valid_src_path(src_path)
    must "#{src_path} is a valid source path" do
      assert Ritsu::SrcFile.is_valid_src_path?(src_path),
        "#{src_path} must be a valid source path"
    end
  end
  
  test_valid_src_path "abc.txt"
  test_valid_src_path "SomeProject/Something_else.cpp"
  test_valid_src_path "mio/koakuma/shadow_gl_renderer.cpp"
  test_valid_src_path ".abc"
  
  def self.test_invalid_src_path(src_path)
    must "#{src_path} is not a valid source path" do
      assert !Ritsu::SrcFile.is_valid_src_path?(src_path),
        "#{src_path} must not be a valid source path"
    end
  end
  
  test_invalid_src_path "abc def"
  test_invalid_src_path "/home/one_users/.tmp"
  test_invalid_src_path ""
  
  must "throw exception if a source file with invalid source path is given" do
    assert_raises ArgumentError do
      Ritsu::SrcFile.new("abc def", @project) 
    end
  end
  
  must "throw exception if two source files have duplicated names" do
    assert_raises ArgumentError do
      Ritsu::SrcFile.new("abc/abc.txt", @project)
      Ritsu::SrcFile.new("abc/abc.txt", @project)
    end
  end
  
  must "now throw exception if source path is a valid source path" do
    assert_nothing_raised do
      Ritsu::SrcFile.new("abc/abc.txt", @project)
    end
  end
  
  must "be added to the owner's src_files array" do
    abc = Ritsu::SrcFile.new("abc/abc.txt", @project)
    assert @project.src_files.include?(abc)
  end
  
  must "return its project correctly when owner is the project" do
    abc = Ritsu::SrcFile.new("abc/abc.txt", @project)
    assert_equal @project, abc.project
  end
  
  must "return its project correct when owheter is a target" do
    target = Ritsu::Targets::Executable.new("def")
    abc = Ritsu::SrcFile.new('abc/abc.txt', target)
    assert_equal target, abc.owner
    assert_equal @project, abc.project
  end
  
  must "compute absolute path correctly" do
    abc = Ritsu::SrcFile.new("abc/abc.txt", @project)
    assert_equal @project.project_dir + "/src/abc/abc.txt", abc.abs_path
  end
end