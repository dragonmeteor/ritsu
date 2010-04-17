require 'rubygems'
require 'active_support'
require File.dirname(__FILE__) + '/utility/accessors'
require File.dirname(__FILE__) + '/utility/instance_set'

module Ritsu
  class ExternalLibrary
    include Ritsu::Utility::Accessors
    include Ritsu::Utility::InstanceSet
    
    attr_reader :name
    attr_accessor :cmake_name
    attr_accessor :cmake_find_script
    attr_accessor :cmake_depend_script
    
    attr_method :cmake_name
    attr_method :cmake_find_script
    attr_method :cmake_depend_script
    
    def initialize(name, options={})
      options = {
        :cmake_name => '',
        :cmake_find_script => '',
        :cmake_depend_script => ''}.merge(options)
      @name = name
      @cmake_name = options[:cmake_name]
      @cmake_find_script = options[:cmake_find_script]
      @cmake_depend_script = options[:cmake_depend_script]
      ExternalLibrary.instances << self
    end
    
    def self.validate_instance(instance)
      if instances.select { |x| x.name == instance.name }.length > 0
        raise ArgumentError.new "external library with name '#{instance.name}' already exists"
      end
    end
    
    def self.find_by_name(name)
      instances.each do |instance|
        if instance.name == name
          return instance
        end
      end
      return nil
    end
  end
end