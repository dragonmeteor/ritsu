require File.dirname(__FILE__) + "/../../test_helpers"

class SharedLibraryTest < Test::Unit::TestCase
  include Ritsu::Targets
  include Ritsu::SetupProjectAndClearEverythingElse
  
  must "be able to be depended on" do
    so = SharedLibrary.new('so')
    assert so.can_be_depended_on?
  end
end