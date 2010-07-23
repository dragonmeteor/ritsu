require File.expand_path(File.dirname(__FILE__) + "/../../../project")
require File.expand_path(File.dirname(__FILE__) + "/../../../src_file")

module Ritsu
  module SrcFiles    
    class VertFile < Ritsu::SrcFile      
      def initialize(src_path, owner)
        super(src_path, owner)
      end
      
      def glsl_file?
        true
      end
      
      def vert_file?
        true
      end
      
      def frag_file?
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
  
    module AddVertFile
      def add_vert_file(path, options={})
        src_path = compute_src_path(path, options)
        vert_file = VertFile.new(src_path, self)
        
        cpp_src_path = compute_src_path(vert_file.cpp_file_base_name, options)
        cpp_file = CppFile.new(cpp_src_path, self)
        
        self.custom_commands << "ADD_CUSTOM_COMMAND(\n" +
          "    OUTPUT ${CMAKE_SOURCE_DIR}/#{cpp_src_path}\n" +
          "    COMMAND define_cpp_string #{vert_file.code_var_name} < ${CMAKE_SOURCE_DIR}/#{vert_file.src_path} > ${CMAKE_SOURCE_DIR}/#{cpp_file.src_path}\n" +
          "    DEPENDS ${CMAKE_SOURCE_DIR}/#{vert_file.src_path})"
      end
      
      def add_vert_files(*paths)
        paths.each do |path|
          add_vert_file(path)
        end
      end
    end
  end
end

module Ritsu
  class Target
    include Ritsu::SrcFiles::AddVertFile
  end
  
  class Project
    include Ritsu::SrcFiles::AddVertFile
  end
end