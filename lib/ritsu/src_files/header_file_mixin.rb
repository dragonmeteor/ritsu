require 'rubygems'
require 'active_support/core_ext/string/inflections'

module Ritsu
  module SrcFiles
    module HeaderFileMixin
      def include_guard
        '__' + project.name.underscore.upcase + '_' + src_path.gsub(/[.\/]+/,'_').upcase + '__'
      end
      
      def header_file?
        true
      end
      
      def cpp_file?
        false
      end
    end
  end
end