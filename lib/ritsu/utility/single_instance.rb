module Ritsu
  module Utility
    module SingleInstance
      module ClassMethods
        def instance
          @instance ||= nil
        end
        
        def set_instance(instance)
          validate_instance(instance)
          @instance = instance
        end
        
        def validate_instance(instance)
        end
      end
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      def initialize(*args, &block)
        initialize_instance(*args, &block)
        self.class.set_instance(self)
      end
      
      def initialize_instance(*args, &block)
        if self.class.superclass.method_defined? :initialize_instance
          super
        end
      end
    end
  end
end