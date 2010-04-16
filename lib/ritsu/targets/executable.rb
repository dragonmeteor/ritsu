require 'rubygems'
require 'active_support'
require 'ritsu/target'
require 'ritsu/utility/instance_set'
require 'ritsu/src_files/executable_cmake_lists'

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