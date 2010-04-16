require File.dirname(__FILE__) + "/../test_helpers"

class BlockTest < Test::Unit::TestCase
  include TestCaseWithFileTestData
  include Ritsu::Utility
  
  def data_dir; File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".rb") end
  
  must "parse lines with no block content correctly" do
    block = Ritsu::Block.new
    block.parse_lines(["abc", "def", "ghi"])
    assert_equal ["abc", "def", "ghi"], block.contents
  end
  
  BLOCK_A_ARRAY = [
    "abc",
    "//<< 123",
    "def",
    "//>> 123",
    "ghi",
    "jkl",
    "//<<",
    "mno",
    "pqr",
    "//>>",
    "stu"
  ]
  
  def check_block_A(block)
    assert_equal 6, block.contents.length
    assert_equal "abc", block.contents[0]
    assert_equal 1, block.contents[1].contents.length
    assert_equal "def", block.contents[1].contents[0]
    assert_equal "ghi", block.contents[2]
    assert_equal "jkl", block.contents[3]
    assert_equal 2, block.contents[4].contents.length
    assert_equal "mno", block.contents[4].contents[0]
    assert_equal "pqr", block.contents[4].contents[1]
    assert_equal "stu", block.contents[5]
  end
  
  must "parse block delimiter correctly" do
    block = Ritsu::Block.new
    block.parse_lines(BLOCK_A_ARRAY)
    check_block_A(block)    
  end

  BLOCK_B_ARRAY = [
    "//<<",
      "//<<",
      "//>>",

      "//<<",
        "//<<",
        "//>>",
      "//>>",
    "//>>",
    
    "//<<",
    "//>>",
  ]
  
  def check_block_B(block)
    assert_equal 2, block.contents.length
    assert_equal 2, block.contents[0].contents.length
    assert_equal 0, block.contents[0].contents[0].contents.length
    assert_equal 1, block.contents[0].contents[1].contents.length
    assert_equal 0, block.contents[0].contents[1].contents[0].contents.length
    assert_equal 0, block.contents[1].contents.length
  end
  
  must "parse nested block correctly" do
    block = Ritsu::Block.new
    block.parse_lines(BLOCK_B_ARRAY)
    check_block_B(block)
  end
  
  must "convert to string correctly" do
    block = Ritsu::Block.new("123",
      [
        "abc",
        "def",
        Ritsu::Block.new("456",
          [
            "ghi"
          ]
        ),
        "jkl"
      ]
    )
    expected_string =
      "//<< 123\n" +
      "abc\n" +
      "def\n" +
      "//<< 456\n" +
      "ghi\n" +
      "//>> 456\n" +
      "jkl\n" +
      "//>> 123"
    assert_equal expected_string, block.to_s
  end
  
  must "convert to string correct when the no_delimiter option is set" do
    block = Ritsu::Block.new("123",
      [
        "abc",
        "def",
        Ritsu::Block.new("456",
          [
            "ghi"
          ]
        ),
        "jkl"
      ]
    )
    expected_string =
      "abc\n" +
      "def\n" +
      "//<< 456\n" +
      "ghi\n" +
      "//>> 456\n" +
      "jkl"
    assert_equal expected_string, block.to_s(:no_delimiter=>true)
  end
  
  file_test "write to file" do
    block = Ritsu::Block.new("123",
      [
        "abc",
        "def",
        Ritsu::Block.new("456",
          [
            "ghi"
          ]
        ),
        "jkl"
      ]
    )
    expected_content = 
      "abc\n" +
      "def\n" +
      "//<< 456\n" +
      "ghi\n" +
      "//>> 456\n" +
      "jkl"
    block.write_to_file(output_path("block.txt"))
    assert_output_file_content expected_content, "block.txt"
  end
  
  must "Block.parse must work correctly on array" do
    block = Ritsu::Block.parse(BLOCK_A_ARRAY)
    check_block_A(block)
  end
  
  must "Block.parse must work correctly on string" do
    block = Ritsu::Block.parse(BLOCK_A_ARRAY.join("\n"))
    check_block_A(block)
  end
  
  file_test "Block_dot_parse must work correct on file" do
    FileRobot.quietly do
      FileRobot.create_file(output_path("block.txt"), BLOCK_A_ARRAY.join("\n"))
    end
    block = Ritsu::Block.parse(:file => output_path("block.txt"))
    check_block_A(block)
  end
end