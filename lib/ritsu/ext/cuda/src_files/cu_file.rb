require File.expand_path(File.dirname(__FILE__) + "/../../../project")
require File.expand_path(File.dirname(__FILE__) + "/../../../src_file")

module Ritsu
  module SrcFiles
    class CuFile < Ritsu::SrcFile
      def initialize(src_path, owner)
        super(src_path, owner)
      end
            
      def header_file?
        false
      end
      
      def cpp_file?
        false
      end
      
      def cu_file?
        true
      end
    end
  
    module AddCuFile
      def add_cu_file(path, options={})
        src_path = compute_src_path(path, options)
        CuFile.new(src_path, self)
      end
      
      def add_cu_files(*paths)
        paths.each do |path|
          add_cu_file(path)
        end
      end
    end
  end
end

module Ritsu
  class Target
    include Ritsu::SrcFiles::AddCuFile
  end
  
  class Project
    include Ritsu::SrcFiles::AddCuFile
  end
end