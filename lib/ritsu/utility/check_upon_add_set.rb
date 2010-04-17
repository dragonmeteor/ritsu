require 'set'

module Ritsu
  module Utility
    class CheckUponAddSet < Set
      def initialize(*args, &block)
        if block_given?
          @check_block = block
        else
          @check_block = Proc.new { }
        end
        super(*args)
      end
    
      def <<(x)
        @check_block.call(self, x)
        super(x)
      end
    
      def add(x)
        @check_block.call(self, x)
        super(x)
      end
    
      def add?(x)
        begin
          @check_block.call(self, x)
          super(x)
        rescue
          nil
        end
      end
    end
  end
end