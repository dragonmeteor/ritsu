require File.expand_path(File.dirname(__FILE__) + '/../utility/check_upon_add_set')

module Ritsu
  module Utility
    module InstanceSet      
      module ClassMethods        
        def instances
          @instances ||= Ritsu::Utility::CheckUponAddSet.new do |s, instance|
            validate_instance(instance)
          end
        end
        
        def validate_instance(instance)
        end
      end
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      def initialize(*args, &block)
        self.class.instances << self
      end
      
      def initialize_instance(*args, &block)
      end
    end
  end
end