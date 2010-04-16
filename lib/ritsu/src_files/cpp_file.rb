require 'ritsu/src_file'
require 'ritsu/project'
require 'ritsu/utility/instance_set'

module Ritsu::SrcFiles
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

module Ritsu
  class Target
    include Ritsu::SrcFiles::AddCppFile
  end
  
  class Project
    include Ritsu::SrcFiles::AddCppFile
  end
end