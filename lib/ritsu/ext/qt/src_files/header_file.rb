require File.expand_path(File.dirname(__FILE__) + "/../../../src_files/header_file")

module Ritsu
  module SrcFiles
    class HeaderFile
      alias_method :initialize_target_before_qt, :initialize
      
      def initialize(src_path, owner, options={})
        options = {:qt_header_file => false}.merge(options)
        initialize_target_before_qt(src_path, owner)
        @qt_header_file = options[:qt_header_file] 
      end
      
      def qt_header_file?
        @qt_header_file
      end
    end
    
    module AddQtHeaderFile
      def add_qt_header_file(path, options={})
        src_path = compute_src_path(path, options)
        HeaderFile.new(src_path, self, :qt_header_file=>true)
      end
      
      def add_qt_header_files(*paths)
        paths.each do |path|
          add_qt_header_file(path)
        end
      end
    end
    
    module AddQtUnit
      include AddCppFile
      include AddQtHeaderFile
      
      def add_qt_unit(name, options={})
        add_cpp_file(name + ".cpp")
        add_qt_header_file(name + ".h")
      end
      
      def add_qt_units(*names)
        names.each do |name|
          add_qt_unit(name)
        end
      end
    end
  end
end

module Ritsu
  class Target
    include Ritsu::SrcFiles::AddQtHeaderFile
    include Ritsu::SrcFiles::AddQtUnit
  end
  
  class Project
    include Ritsu::SrcFiles::AddQtHeaderFile
    include Ritsu::SrcFiles::AddQtUnit
  end
end
