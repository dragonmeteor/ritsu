require File.expand_path(File.dirname(__FILE__) + '/utility/file_robot')
require File.expand_path(File.dirname(__FILE__) + '/utility/instance_set')
require File.expand_path(File.dirname(__FILE__) + '/utility/strings')

module Ritsu
  class ProjectGenerator
    attr_reader :name
    
    def self.generator_classes
      @generator_classes ||= {}
    end
    
    def self.is_valid_generator_name?(name)
      Ritsu::Utility::Strings::is_c_name?(name)
    end
    
    def initialize(name)
      if !ProjectGenerator.is_valid_generator_name?(name)
        raise ArgumentError.new("'#{name}' is not a valid project name (i.e., a C name)")
      end
      @name = name
    end
    
    def self.validate_instance(instance)
      if instances.select { |x| x.name == instance.name }.length > 0
        raise ArgumentError.new("project generator with name '#{instance.name}' already exists")
      end
    end
    
    def generate(*args)
      raise NotImplementedError.new
    end
  end
end