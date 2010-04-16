require 'rubygems'
require 'active_support'
require 'ritsu/target'
require 'ritsu/utility/instance_set'
require 'ritsu/src_files/static_library_cmake_lists'

module Ritsu::Targets
  class StaticLibrary < Ritsu::Target
    attr_reader :cmake_lists
    
    def initialize(name, options={})
      super(name, options)
      @cmake_lists = Ritsu::SrcFiles::StaticLibraryCmakeLists.new(self)
    end
    
    def can_be_depended_on?
      true
    end
  end
end

module Ritsu
  class Project
    def add_static_library(name)
      static_library = Ritsu::Targets::StaticLibrary.new(name, :project=>self)
      yield static_library if block_given?
    end
  end
end