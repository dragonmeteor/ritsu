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
      initialize_cmake_lists
    end
    
    protected
    def initialize_cmake_lists
      @cmake_lists = Ritsu::SrcFiles::SharedLibraryCmakeLists.new(self)
    end
      
    public
    def can_be_depended_on?
      true
    end
    
    def executable?
      false
    end
    
    def shared_library?
      true
    end
    
    def static_library?
      false
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