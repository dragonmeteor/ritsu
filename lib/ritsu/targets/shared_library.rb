require 'rubygems'
require 'active_support'
require File.expand_path(File.dirname(__FILE__) + '/library')
require File.expand_path(File.dirname(__FILE__) + '/../utility/instance_set')
require File.expand_path(File.dirname(__FILE__) + '/../src_files/shared_library_cmake_lists')

module Ritsu::Targets
  class SharedLibrary < Ritsu::Targets::Library
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