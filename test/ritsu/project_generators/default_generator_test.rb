require File.dirname(__FILE__) + "/../../test_helpers"

class DefaultGeneratorTest < Test::Unit::TestCase
  include TestCaseWithFileTestData
  include Ritsu::Utility
  
  def data_dir; File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".rb") end
      
  file_test "generate" do
    FileRobot.quietly do
      Ritsu::ProjectGenerators::DefaultGenerator.new.generate('mio', output_dir)
    end
    
    assert_output_file_exists("mio")
    assert_output_file_exists("mio/build")
    assert_output_file_exists("mio/src")
    assert_output_file_exists("mio/meta")
    assert_output_file_exists("mio/Thorfile")
    assert_output_file_exists("mio/meta/project.rb")
    
    expected_project_rb_content = <<-RUBY
require 'ritsu'

Ritsu::Project.create('mio') do |p|

  ##################
  # YOUR CODE HERE #
  ##################

end
RUBY
    assert_output_file_content(expected_project_rb_content, "mio/meta/project.rb")
  end
end