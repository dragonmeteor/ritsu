require File.dirname(__FILE__) + "/../../test_helpers"

class StaticLibraryTest < Test::Unit::TestCase
  include Ritsu::Targets
  include SetupProjectAndClearEverythingElse
  
  must "be able to be depended on" do
    a = StaticLibrary.new('a')
    assert a.can_be_depended_on?
  end
end