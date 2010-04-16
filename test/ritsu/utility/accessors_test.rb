require File.dirname(__FILE__) + "/../../test_helpers"


class AccessorsTest < Test::Unit::TestCase
  class A
    include Ritsu::Utility::Accessors
    attr_method :x
  end

  must "attr_equal works correctly" do
    a = A.new
    a.x 10
    assert_equal 10, a.x
  end
end