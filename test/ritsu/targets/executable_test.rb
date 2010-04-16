require File.dirname(__FILE__) + "/../../test_helpers"

class ExecutableTest < Test::Unit::TestCase
  include Ritsu::Targets
  include SetupProjectAndClearEverythingElse
  
  must "not be able to be depended on" do
    exe = Executable.new('exe')
    assert !exe.can_be_depended_on?
  end
end