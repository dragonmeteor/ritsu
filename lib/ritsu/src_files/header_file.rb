require File.dirname(__FILE__) + '/../src_file'
require File.dirname(__FILE__) + '/../project'
require File.dirname(__FILE__) + '/../utility/instance_set'
require File.dirname(__FILE__) + '/../utility/file_robot'
require File.dirname(__FILE__) + '/header_file_mixin'

module Ritsu
  module SrcFiles
    class HeaderFile < Ritsu::SrcFile
      include HeaderFileMixin
    
      def initialize(src_path, owner)
        super(src_path, owner)
      end
      
      def create
        Ritsu::Utility::FileRobot.create_file(abs_path,
          "#ifndef #{include_guard}\n" +
          "#define #{include_guard}\n" +
          "\n" +
          "////////////////////\n" +
          "// YOUR CODE HERE //\n" +
          "////////////////////\n" +
          "\n" +
          "#endif\n")
      end          
    end
    
    module AddHeaderFile
      def add_header_file(path, options={})
        src_path = compute_src_path(path, options)
        HeaderFile.new(src_path, self)
      end
      
      def add_header_files(*paths)
        paths.each do |path|
          add_header_file(path)
        end
      end
    end
  end
end

module Ritsu
  class Target
    include Ritsu::SrcFiles::AddHeaderFile
  end
  
  class Project
    include Ritsu::SrcFiles::AddHeaderFile
  end
end