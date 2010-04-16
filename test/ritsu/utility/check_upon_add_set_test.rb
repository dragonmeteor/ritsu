require File.dirname(__FILE__) + "/../../test_helpers"

class CheckUponAddSetTest < Test::Unit::TestCase
  include Ritsu::Utility
  
  must "behave like normal set when given no block" do
    s = CheckUponAddSet.new
    s << 1 << 2 << "abc"
    assert s.include?(1)
    assert s.include?(2)
    assert s.include?("abc")
    s.delete(1)
    assert !s.include?(1)
  end
  
  must "preform check when block is given" do
    s = CheckUponAddSet.new do |s,x|
      if x > 10
        raise ArgumentError.new("inserted value more than 10!")
      end
    end
    assert_nothing_raised do
      s << 1
      s << 2
      s << 10
      s << -1
    end
    assert_raises ArgumentError do
      s << 11
    end
  end
end