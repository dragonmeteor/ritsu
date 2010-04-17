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
    end
  end
end