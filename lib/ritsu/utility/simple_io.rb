module Ritsu
  module Utility
    ##
    # This class is lifted from rubigen's SimpleLogger
    class SimpleIO    
      attr_accessor :input
      attr_accessor :output
      attr_accessor :quiet

      def initialize(input = $stdin, output = $stdout)
        @input = input
        @output = output
        @quiet = false
        @level = 0
      end

      def log(status, message, &block)
        @output.print("%12s %s%s\n" % [status, ' ' * @level, message]) unless quiet
        indent(&block) if block_given?
      end

      def indent(&block)
        @level += 1
        if block_given?
          begin
            block.call
          ensure
            outdent
          end
        end
      end

      def outdent
        @level -= 1
        if block_given?
          begin
            block.call
          ensure
            indent
          end
        end
      end
    
      def ask_yes_no_all(message)
        @output.print("#{message} (yes/no/all): ")
        answer = @input.gets.strip
        case answer
        when /^y(es)?$/i
          return :yes
        when /^no?$/i
          return :no
        when /^a(ll)?$/i
          return :all
        else
          ask_yes_no_all(message)
        end
      end

      private
        def method_missing(method, *args, &block)
          log(method.to_s, args.first, &block)
        end
    end
  end
end