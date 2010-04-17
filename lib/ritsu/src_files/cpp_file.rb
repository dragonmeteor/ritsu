require File.dirname(__FILE__) + '/../src_file'
require File.dirname(__FILE__) + '/../project'
require File.dirname(__FILE__) + '/../utility/instance_set'

module Ritsu
  module SrcFiles
    class CppFile < Ritsu::SrcFile    
      def initialize(src_path, owner)
        super(src_path, owner)
      end
    end
  
    module AddCppFile
      def add_cpp_file(path, options={})
        src_path = compute_src_path(path, options)
        CppFile.new(src_path, self)
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