lib_dir = File.dirname(__FILE__) + '/../lib' 
require 'test/unit' 
$:.unshift lib_dir unless $:.include?(lib_dir)
require 'ritsu'

module SetupProjectAndClearEverythingElse
  def setup_project(name='project')
    Ritsu::Target.instances.clear
    Ritsu::SrcFile.instances.clear
    Ritsu::ExternalLibrary.instances.clear
    @project = Ritsu::Project.create(name)    
  end
  
  def setup
    setup_project
  end
end

module Test::Unit
  class TestCase
    def self.must(name, &block)
      test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
      defined = instance_method(test_name) rescue false
      raise "#{test_name} is already defined in #{self}" if defined
      if block_given?
        define_method(test_name, &block)
      else
        define_method(test_name) do
          flunk "No implementation provided for #{name}"
        end
      end
    end
  end
end

module TestCaseWithFileTestData
  module ClassMethods
    def file_test(name, &block)
      case_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
      if !Ritsu::Utility::Strings::is_c_name?(case_name.to_s)
        raise "'#{name}' does not yield a valid test case name (i.e., a C name)"
      end
      defined = instance_method(case_name) rescue false
      raise "#{case_name} is already defined in #{self}" if defined
      if block_given?
        define_method(case_name) do
          init_data_dir
          instance_eval(&block)
        end
      else
        define_method(case_name) do
          flunk "No implmentation provided for #{case_name}"
        end
      end
    end
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  def init_data_dir
    FileUtils.mkdir_p(data_dir)
    FileUtils.mkdir_p(static_dir)
    FileUtils.mkdir_p(output_dir)
    FileUtils.rm_r(Dir.glob(output_dir + '/*'), :force=>true)
  end
  
  def data_dir
    raise NotImplementedError.new
  end
  
  def data_path(path)
    data_dir + '/' + path
  end
    
  def output_dir
    data_dir + '/output'
  end
  
  def output_path(path)
    output_dir + '/' + path
  end
  
  def static_dir
    data_dir + '/static'
  end
  
  def static_path(path)
    static_dir + '/' + path
  end
  
  def assert_file_exists(filename)
    assert_block "#{filename} must exists" do
      File.exists?(filename)
    end
  end
  
  def assert_file_not_exist(filename)
    assert_block "#{filename} must not exist" do
      !File.exists?(filename)
    end
  end
  
  def assert_data_file_exists(filename)
    assert_file_exists(data_path(filename))
  end
  
  def assert_data_file_not_exist(filename)
    assert_file_not_exist(data_path(filename))
  end
  
  def assert_output_file_exists(filename)
    assert_file_exists(output_path(filename))
  end
  
  def assert_output_file_not_exist(filename)
    assert_file_not_exist(output_path(filename))
  end
  
  def assert_file_content(content, filename)
    assert_equal content, IO.read(filename)
      "content of #{filename} differs from expected"
  end
  
  def assert_file_compare(expected_file, actual_file)
    assert_equal IO.read(expected_file), IO.read(actual_file),
      "content of #{actual_file} differs from #{expected_file}"
  end
  
  def assert_output_file_compare_to_static(path)
    assert_file_compare(static_path(path), output_path(path))
  end
  
  def assert_output_file_content(content, path)
    assert_file_content(content, output_path(path))
  end
end