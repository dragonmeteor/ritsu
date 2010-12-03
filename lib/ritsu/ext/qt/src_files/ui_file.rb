require File.expand_path(File.dirname(__FILE__) + "/../../../project")
require File.expand_path(File.dirname(__FILE__) + "/../../../src_file")

module Ritsu
  module SrcFiles
    class UiFile < Ritsu::SrcFile
      def initialize(src_path, owner)
        super(src_path, owner)
      end
            
      def header_file?
        false
      end
      
      def cpp_file?
        false
      end
      
      def ui_file?
        true
      end
    end
  
    module AddUiFile
      def add_ui_file(path, options={})
        src_path = compute_src_path(path, options)
        UiFile.new(src_path, self)
      end
      
      def add_ui_files(*paths)
        paths.each do |path|
          add_cu_file(path)
        end
      end
    end
  end
end

module Ritsu
  class Target
    include Ritsu::SrcFiles::AddUiFile
  end
  
  class Project
    include Ritsu::SrcFiles::AddUiFile
  end
end