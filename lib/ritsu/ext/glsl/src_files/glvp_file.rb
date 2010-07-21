require File.dirname(__FILE__) + '/../../../src_file'
require File.dirname(__FILE__) + '/../../../project'
require File.dirname(__FILE__) + '/../../../utility/instance_set'

module Ritsu
  module SrcFiles
    module GlvpFileMixin
      def glsl_file?
        true
      end
      
      def glvp_file?
        true
      end
      
      def glfp_file?
        false
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
    
    class GlvpFile < Ritsu::SrcFile
      include GlvpFileMixin
      
      def initialize(src_path, owner)
        super(src_path, owner)
      end
    end
  
    module AddGlvpFile
      def add_glvp_file(path, options={})
        src_path = compute_src_path(path, options)
        glvp_file = GlvpFile.new(src_path, self)
        
        cpp_src_path = compute_src_path(glvp_file.cpp_file_base_name, options)
        cpp_file = CppFile.new(cpp_src_path, self)
        
        self.custom_commands << "ADD_CUSTOM_COMMAND(\n" +
          "    OUTPUT ${CMAKE_SOURCE_DIR}/#{cpp_src_path}\n" +
          "    COMMAND define_cpp_string #{glvp_file.code_var_name} < ${CMAKE_SOURCE_DIR}/#{glvp_file.src_path} > ${CMAKE_SOURCE_DIR}/#{cpp_file.src_path}\n" +
          "    DEPENDS ${CMAKE_SOURCE_DIR}/#{glvp_file.src_path})"
      end
      
      def add_glvp_files(*paths)
        paths.each do |path|
          add_glvp_file(path)
        end
      end
    end
  end
end

module Ritsu
  class Target
    include Ritsu::SrcFiles::AddGlvpFile
  end
  
  class Project
    include Ritsu::SrcFiles::AddGlvpFile
  end
end