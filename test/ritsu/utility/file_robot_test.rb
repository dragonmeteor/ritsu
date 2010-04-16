require File.dirname(__FILE__) + "/../../test_helpers"

class FileRobotTest < Test::Unit::TestCase
  include Ritsu::Utility
  include TestCaseWithFileTestData
  
  def data_dir; File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".rb") end
  
  def setup
    init_data_dir
    @input = StringIO.new
    @output = StringIO.new
    FileRobot.input = @input
    FileRobot.output = @output
  end
  
  def provide_input(string)
    @input << string
    @input.rewind
  end
    
  def expect_output(string)
    assert_equal string, @output.string
  end
    
  must "force must be initially false" do
    assert !FileRobot.force
  end
  
  must "quiet must be initially false" do
    assert !FileRobot.quiet
  end
  
  file_test "create empty file" do
    FileRobot.create_file(output_path("abc.txt"))
    assert_output_file_exists "abc.txt"
    assert_output_file_content "", "abc.txt"
    expect_output("      create #{output_dir}/abc.txt\n")
  end
  
  file_test "create file with content" do
    FileRobot.create_file(output_path("abc.txt"), "def")
    assert_output_file_content "def", "abc.txt"
    expect_output("      create #{output_dir}/abc.txt\n")
  end
  
  file_test "create parent directories when creating a file" do
    FileRobot.create_file(output_path("a/b/c/def.txt"), "def")
    assert_output_file_exists "a/b/c/def.txt"
    expect_output(
      "      create #{output_dir}/a/b/c\n" +
      "      create #{output_dir}/a/b/c/def.txt\n"
    )
  end
  
  file_test "create directory" do
    FileRobot.create_dir(output_path("abc/def/ghi"))
    assert_file_exists(output_path("abc/def/ghi"))
    expect_output("      create #{output_dir}/abc/def/ghi\n")
  end
  
  file_test "display exist message when dir already exist" do
    FileRobot.create_dir(output_path("abc"))
    FileRobot.create_dir(output_path("abc"))
    expect_output(
      "      create #{output_dir}/abc\n" +
      "       exist #{output_dir}/abc\n"
    )
  end
  
  ['no', 'n', 'N', 'NO'].each do |answer|
    file_test "ask user when file exist and do nothing when user says #{answer}" do
      provide_input(answer)
      FileRobot.create_file(output_path("abc.txt"), "abc")
      FileRobot.create_file(output_path("abc.txt"), "def")
      expect_output(
        "      create #{output_dir}/abc.txt\n" +
           "overwrite #{output_dir}/abc.txt? (yes/no/all): " +
        "       exist #{output_dir}/abc.txt\n"
      )
      assert_output_file_content "abc", "abc.txt"
    end
  end
  
  ['yes', 'y', 'YES', 'Yes', 'Y'].each do |answer|
    file_test "ask user when file exist and overwrite when user says #{answer}" do
      provide_input(answer)
      FileRobot.create_file(output_path("abc.txt"), "abc")
      FileRobot.create_file(output_path("abc.txt"), "def")
      expect_output(
        "      create #{output_dir}/abc.txt\n" +
           "overwrite #{output_dir}/abc.txt? (yes/no/all): " +
        "   overwrite #{output_dir}/abc.txt\n"
      )
      assert_output_file_content "def", "abc.txt"
    end
  end
    
  ['ye', 'non', 'Nevar', 'programming'].each do |answer|
    file_test "ask user when file exist and ask again when user says #{answer}" do
      provide_input(answer + "\nno")
      FileRobot.create_file(output_path("abc.txt"), "abc")
      FileRobot.create_file(output_path("abc.txt"), "def")
      expect_output(
        "      create #{output_dir}/abc.txt\n" +
           "overwrite #{output_dir}/abc.txt? (yes/no/all): " +
           "overwrite #{output_dir}/abc.txt? (yes/no/all): " +
        "       exist #{output_dir}/abc.txt\n"
      )
      assert_output_file_content "abc", "abc.txt"
    end
  end
  
  file_test "remove file" do
    FileRobot.create_file(output_path("abc.txt"), "abc")
    assert_output_file_exists("abc.txt")
    FileRobot.remove_file(output_path("abc.txt"))
    assert_output_file_not_exist("abc.txt")
  end
  
  file_test "write a message if file to remove does not exist" do
    FileRobot.remove_file(output_path("abc.txt"))
    expect_output(
      "   not exist #{output_dir}/abc.txt\n"
    )
  end
  
  file_test "write a message if file to remove is not a file" do
    FileRobot.create_dir(output_path("abc.txt"))
    assert_output_file_exists("abc.txt")
    FileRobot.remove_file(output_path("abc.txt"))
    expect_output(
      "      create #{output_dir}/abc.txt\n" +
      "    not file #{output_dir}/abc.txt\n"
    )
    assert_output_file_exists("abc.txt")
  end
  
  file_test "remove dir" do
    FileRobot.create_dir(output_path("abc"))
    assert_output_file_exists("abc")
    FileRobot.remove_dir(output_path("abc"))
    assert_output_file_not_exist("abc")
  end
  
  file_test "write a message if dir to remove does not exist" do
    FileRobot.remove_file(output_path("abc"))
    expect_output(
      "   not exist #{output_dir}/abc\n"
    )
  end
  
  file_test "write a message if dir to remove is not a dir" do
    FileRobot.create_file(output_path("abc"), "")
    assert_output_file_exists("abc")
    FileRobot.remove_dir(output_path("abc"))
    expect_output(
      "      create #{output_dir}/abc\n" +
      "     not dir #{output_dir}/abc\n"
    )
    assert_output_file_exists("abc")    
  end
  
  file_test "write a message if dir to remove is not empty" do
    FileRobot.create_dir(output_path("abc"))
    FileRobot.create_file(output_path("abc/def.txt"), "")
    assert_output_file_exists('abc/def.txt')
    FileRobot.remove_dir(output_path("abc"))
    expect_output(
      "      create #{output_dir}/abc\n" +
      "      create #{output_dir}/abc/def.txt\n" +
      "   not empty #{output_dir}/abc\n"
    )
    assert_output_file_exists("abc/def.txt")
  end
end