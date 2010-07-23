require File.expand_path(File.dirname(__FILE__) + "/../src_file")

module Ritsu
  module SrcFiles
    class ProjectConfigHeaderFile < Ritsu::SrcFile
      def initialize(project)
        super("config.h", project)
      end
      
      def include_in_source_files?
        false
      end
    end
  end
end