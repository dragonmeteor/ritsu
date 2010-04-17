require 'rubygems'
require 'active_support'
require File.dirname(__FILE__) + '/../target'
require File.dirname(__FILE__) + '/../utility/instance_set'
require File.dirname(__FILE__) + '/../src_files/shared_library_cmake_lists'

module Ritsu::Targets
  class SharedLibrary < Ritsu::Target
    attr_reader :cmake_lists
    
    def initialize(name, options={})
      super(name, options)
      @cmake_lists = Ritsu::SrcFiles::SharedLibraryCmakeLists.new(self)
    end
        
    def can_be_depended_on?
      true
    end
  end
end

module Ritsu
  class Project
    def add_shared_library(name)
      shared_library = Ritsu::Targets::SharedLibrary.new(name, :project=>self)
      yield shared_library if block_given?
    end
  end
end