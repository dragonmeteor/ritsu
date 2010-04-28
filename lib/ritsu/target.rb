require 'rubygems'
require 'active_support'
require 'set'
require 'pathname'
require File.dirname(__FILE__) + '/utility/instance_set'
require File.dirname(__FILE__) + '/utility/strings'
require File.dirname(__FILE__) + '/project'
require File.dirname(__FILE__) + '/utility/check_upon_add_set'
require File.dirname(__FILE__) + '/external_library'
require File.dirname(__FILE__) + '/utility/instance_dependencies'

module Ritsu
  class Target
    include Ritsu::Utility::InstanceSet
    include Ritsu::Utility::InstanceDependencies
    include Ritsu::Utility::Strings
    
    dependencies_between :targets
    
    attr_reader :name
    attr_reader :dependency_libraries
    attr_reader :project
    attr_reader :src_files
    attr_reader :custom_commands
    attr_accessor :topological_order
    
    def initialize(name, options={})
      options = {:project => Ritsu::Project.instance}.merge(options)
      
      if !is_c_name?(name)
        raise ArgumentError.new(
          "target name must be a valid C name")
      end
    
      @name = name
      @dependency_libraries = Set.new
      @project = options[:project]
      @src_files = Set.new
      @custom_commands = []
      @topological_order = 0
      
      Target.instances << self
      @project.targets << self
    end
    
    def self.validate_instance(instance)
      if instances.select { |x| x.name == instance.name }.length > 1
        raise "target with name '#{instance.name}' already exists"
      end
    end
        
    def src_dir
      self.name
    end
    
    def abs_dir
      File.expand_path(project.project_dir + "src/#{src_dir}")
    end
        
    def compute_src_path(path, options={})
      options = {:relative_to => :target}.merge(options)
      
      case options[:relative_to]
      when :target
        self.src_dir + "/" + path
      when :src
        path
      when :absolute
        src_dir = Pathname.new(project.src_dir)
        input_path = Pathname.new(path)
        input_path.relative_path_from(src_dir).to_s
      else
        raise ArgumentError.new("option :relative_to must be one of :target, :src, and :absolute")
      end
    end
    
    def include_file(filename, options={})
      file_content = Ritsu::Utility::Files.read(filename)
      instance_eval(file_content)
    end
    
    def update
      src_files.each do |src_file|
        src_file.update
      end
    end    
    
    def self.find_by_name(name)
      instances.each do |instance|
        if instance.name == name
          return instance
        end
      end
      return nil
    end
    
    def add_external_library(name)
      external_library = Ritsu::ExternalLibrary.find(name.to_s)
      if !external_library.nil?
        dependency_libraries << external_library
      else
        raise ArgumentError.new("no external library with name '#{name}'")
      end
    end
    
    def add_dependency_target(target_or_target_name)
      if target_or_target_name.kind_of?(String)
        dependency = Target.find_by_name(target_or_target_name)
        if dependency.nil?
          raise ArgumentError.new("no target with name '#{name}'")
        end
      else
        dependency = target_or_target_name
      end
      
      dependency_targets << dependency
      dependency.dependency_libraries.each do |library|
        dependency_libraries << library
      end
    end
    
    def dependency_targets_sorted_by_topological_order
      Target.compute_topological_orders
      result = dependency_targets.to_a
      result.sort! {|x,y| x.topological_order - y.topological_order}
      result
    end
  end
  
  class Project
    def targets_sorted_by_topological_order
      Target.compute_topological_orders
      result = targets.to_a
      result.sort! {|x,y| x.topological_order - y.topological_order}
      result
    end
  end
end