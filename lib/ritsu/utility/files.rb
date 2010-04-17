module Ritsu
  module Utility
    module Files
      def read(filename)
        f = File.new(filename)
        result = f.read
        f.close
        result
      end
      module_function :read
    end
  end
end