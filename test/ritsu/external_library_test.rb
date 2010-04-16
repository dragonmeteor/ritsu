require File.dirname(__FILE__) + "/../test_helpers"

class ExternalLibraryTest < Test::Unit::TestCase
  include Ritsu
  
  def setup
    ExternalLibrary.instances.clear
  end
  
  must "initialize correctly" do
    qt = ExternalLibrary.new('qt')
    assert_equal 'qt', qt.name
    assert_equal '', qt.cmake_name
    assert_equal '', qt.cmake_depend_script
    assert_equal '', qt.cmake_find_script
    assert_equal 1, ExternalLibrary.instances.size
  end
  
  must "be able to use cmake_name, cmake_depend_script, and cmake_find_script methods in instance_eval" do
    qt = ExternalLibrary.new('qt')
    qt.instance_eval do
      cmake_name 'Qt'
      cmake_depend_script 'abc'
      cmake_find_script 'def'
    end
    assert_equal 'Qt', qt.cmake_name
    assert_equal 'abc', qt.cmake_depend_script
    assert_equal 'def', qt.cmake_find_script
  end
  
  must "raise exception if create external library with duplicated names" do
    ExternalLibrary.new('qt')
    assert_raises(ArgumentError) do
      ExternalLibrary.new('qt')
    end
  end
end