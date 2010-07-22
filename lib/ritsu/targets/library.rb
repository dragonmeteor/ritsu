require File.expand_path(File.dirname(__FILE__) + "/../target")
require File.expand_path(File.dirname(__FILE__) + "/../utility/accessors")

module Ritsu::Targets
  class Library < Ritsu::Target
    include Ritsu::Utility::Accessors
    
    attr_accessor :cmake_depend_script
    attr_method :cmake_depend_script
    
    def initialize(name, options={})
      options = {:cmake_depend_script => ""}.merge(options)
      super(name, options)
      @cmake_depend_script = options[:cmake_depend_script]
    end
    
    def can_be_depended_on?
      true
    end
    
    def executable?
      false
    end
    
    def library?
      true
    end
  end
end
