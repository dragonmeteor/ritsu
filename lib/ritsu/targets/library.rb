require File.dirname(__FILE__) + "/../target"

module Ritsu::Targets
  class Library < Ritsu::Target
    attr_accessor :cmake_depend_script
    
    def initialize(name, options={})
      options = {:cmake_depend_script => ""}.merge(options)
      super(name, options)
    end
    
    def can_be_depended_on?
      true
    end
    
    def executable?
      false
    end
  end
end
