require 'rubygems'
require 'active_support/core_ext/string/inflections'
require File.dirname(__FILE__) + '/../../../src_file'
require File.dirname(__FILE__) + '/../../../project'
require File.dirname(__FILE__) + '/../../../utility/instance_set'
require File.dirname(__FILE__) + '/../../../src_files/cpp_file'

module Ritsu
  module SrcFiles
    module GlfpFileMixin
      def glsl_file?
        true
      end
      
      def glvp_file?
        false
      end
      
      def glfp_file?
        true
      end
      
      def header_file?
        false
      end
      
      def cpp_file?
        false
      end
      
      def cpp_file_base_name
        base_name.gsub(/[.\/]+/,'_') + ".cpp"
      end
      
      def code_var_name
        src_path.gsub(/[.\/]+/,'_') + "_code"
      end
    end
    
    class GlfpFile < Ritsu::SrcFile
      include GlfpFileMixin
      
      def initialize(src_path, owner)
        super(src_path, owner)
      end
    end
  
    module AddGlfpFile
      def add_glfp_file(path, options={})
        src_path = compute_src_path(path, options)
        glfp_file = GlfpFile.new(src_path, self)
        
        cpp_src_path = compute_src_path(glfp_file.cpp_file_base_name, options)
        cpp_file = CppFile.new(cpp_src_path, self)
        
        self.custom_commands << "ADD_CUSTOM_COMMAND(\n" +
          "    OUTPUT ${CMAKE_SOURCE_DIR}/#{cpp_src_path}\n" +
          "    COMMAND define_cpp_string #{glfp_file.code_var_name} < ${CMAKE_SOURCE_DIR}/#{glfp_file.src_path} > ${CMAKE_SOURCE_DIR}/#{cpp_file.src_path}\n" +
          "    DEPENDS ${CMAKE_SOURCE_DIR}/#{glfp_file.src_path})"
      end
      
      def add_glfp_files(*paths)
        paths.each do |path|
          add_glfp_file(path)
        end
      end
    end
  end
end

module Ritsu
  class Target
    include Ritsu::SrcFiles::AddGlfpFile
  end
  
  class Project
    include Ritsu::SrcFiles::AddGlfpFile
  end
end