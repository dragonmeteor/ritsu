module Ritsu
  module Utility
    module Accessors
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def attr_method_single(name)
          name = name.to_s
          module_eval <<-_RUBY
            def #{name}(*args)
              if args.length == 0
                @#{name} ||= nil
              elsif args.length == 1
                @#{name} = args[0]
              end
            end
          _RUBY
        end
        
        def attr_method(*names)
          names.each do |name|
            attr_method_single(name)
          end
        end
      end      
    end
  end
end