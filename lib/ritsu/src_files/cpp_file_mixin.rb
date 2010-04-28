module Ritsu
  module SrcFiles
    module CppFileMixin
      def header_file?
        false
      end
      
      def cpp_file?
        true
      end
    end
  end
end