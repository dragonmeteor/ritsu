module Ritsu
  module Utility
    module Strings
      def is_underscore_case?(str)
        str =~ /^[a-z_][0-9a-z_]*$/
      end
      module_function :is_underscore_case?

      def is_c_name?(str)
        str =~ /^[A-Za-z_]\w*$/
      end
      module_function :is_c_name?

      def first(len, str)
        if str.length > count
          str[0..(len-1)]
        else
          str
        end
      end
      module_function :first
      
      def leading_whitespaces(str)
        /^\s*/.match(str)[0]
      end
      module_function :leading_whitespaces
      
      def convert_whitespaces_to_spaces(str, options={})
        options = {:soft_tab => 4}.merge(options)
        str.sub("\t", " "*options[:soft_tab]).sub(/\n\r/, "")
      end
      module_function :convert_whitespaces_to_spaces
      
      def leading_spaces(str, options={})
        Ritsu::Utility::Strings.convert_whitespaces_to_spaces(
          Ritsu::Utility::Strings.leading_whitespaces(str), options)
      end
      module_function :leading_spaces
    end
  end
end