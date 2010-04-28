require 'rubygems'
require 'active_support'
require File.dirname(__FILE__) + '/../target'
require File.dirname(__FILE__) + '/../utility/instance_set'
require File.dirname(__FILE__) + '/../src_files/executable_cmake_lists'

module Ritsu::Targets
  class Executable < Ritsu::Target
    attr_reader :cmake_lists
    
    def initialize(name, options={})
      super(name, options)
      @cmake_lists = Ritsu::SrcFiles::ExecutableCmakeLists.new(self)
    end
    
    def can_be_depended_on?
      false
    end
    
    def executable?
      true
    end
    
    def shared_library?
      false
    end
    
    def static_library?
      false
    end
  end
end

module Ritsu
  class Project
    def add_executable(name)
      executable = Ritsu::Targets::Executable.new(name, :project=>self)
      yield executable if block_given?
    end
  end
end