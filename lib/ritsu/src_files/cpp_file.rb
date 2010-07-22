require File.expand_path(File.dirname(__FILE__) + '/../src_file')
require File.expand_path(File.dirname(__FILE__) + '/../project')
require File.expand_path(File.dirname(__FILE__) + '/../utility/instance_set')
require File.expand_path(File.dirname(__FILE__) + '/cpp_file_mixin')

module Ritsu
  module SrcFiles
    class CppFile < Ritsu::SrcFile
      include CppFileMixin
      
      def initialize(src_path, owner)
        super(src_path, owner)
      end
    end
  
    module AddCppFile
      def add_cpp_file(path, options={})
        src_path = compute_src_path(path, options)
        CppFile.new(src_path, self)
      end
      
      def add_cpp_files(*paths)
        paths.each do |path|
          add_cpp_file(path)
        end
      end
    end
  end
end

module Ritsu
  class Target
    include Ritsu::SrcFiles::AddCppFile
  end
  
  class Project
    include Ritsu::SrcFiles::AddCppFile
  end
end