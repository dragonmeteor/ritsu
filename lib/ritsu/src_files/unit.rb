require File.dirname(__FILE__) + '/../src_file'
require File.dirname(__FILE__) + '/cpp_file'
require File.dirname(__FILE__) + '/header_file'

module Ritsu
  module SrcFiles
    module AddUnit
      include AddCppFile
      include AddHeaderFile
      
      def add_unit(name, options={})
        add_cpp_file(name + ".cpp")
        add_header_file(name + ".h")
      end
      
      def add_units(*names)
        names.each do |name|
          add_unit(name)
        end
      end
    end
  end
end

module Ritsu
  class Target
    include Ritsu::SrcFiles::AddUnit
  end
  
  class Project
    include Ritsu::SrcFiles::AddUnit
  end
end