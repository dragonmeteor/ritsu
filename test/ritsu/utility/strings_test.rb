require File.dirname(__FILE__) + "/../../test_helpers"

class StringTest < Test::Unit::TestCase
  include Ritsu::Utility::Strings
  
  ['abc', 'abc_def_ghi', 'abc123_1939'].each do |str|
    must "is_underscore_case?(#{str}) be true" do
      assert is_underscore_case?(str)
    end
  end
  
  ['SomethingAweful', '9adef'].each do |str|
    must "is_underscore_case?(#{str}) be false" do
      assert !is_underscore_case?(str)
    end
  end
  
  ['abc', '_', '_abc', 'Something_Aweful', 'test_create_empty_file'].each do |str|
    must "is_c_name?(#{str}) be true" do
      assert is_c_name?(str)
    end
  end
  
  ['32abc', 'dog cat', 'meow?'].each do |str|
    must "is_c_name?(#{str}) be false" do
      assert !is_c_name?(str)
    end
  end
end