require File.expand_path(File.dirname(__FILE__) + "/../../project")

module Ritsu
  class Project
    def setup_cuda
      add_external_library("cuda") do |e|
        e.cmake_find_script "FIND_PACKAGE(CUDA REQUIRED)"
        e.cmake_depend_script "INCLUDE_DIRECTORIES(${CUDA_INCLUDE_DIRS})"
        e.cuda_depend_script "CUDA_INCLUDE_DIRECTORIES(${CUDA_INCLUDE_DIRS})"
        e.cmake_name "${CUDA_LIBRARIES}"
      end
    end
    
    def add_cuda_executable(name)
      executable = Ritsu::Targets::Executable.new(name, :project=>self, :cuda_target=>true)
      executable.add_external_library "cuda"
      yield executable if block_given?
    end
    
    def add_cuda_shared_library(name)
      shared_library = Ritsu::Targets::SharedLibrary.new(name, :project=>self, :cuda_target=>true)
      shared_library.add_external_library "cuda"
      yield shared_library if block_given?
    end
    
    def add_cuda_static_library(name)
      static_library = Ritsu::Targets::StaticLibrary.new(name, :project=>self, :cuda_target=>true)
      static_library.add_external_library "cuda"
      yield static_library if block_given?
    end
  end
end