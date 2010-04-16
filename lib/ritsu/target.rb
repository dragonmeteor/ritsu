require 'rubygems'
require 'active_support'
require 'ritsu/utility/instance_set'
require 'ritsu/utility/strings'
require 'ritsu/project'
require 'ritsu/utility/check_upon_add_set'
require 'set'
require 'pathname'
require 'ritsu/external_library'

module Ritsu
  class Target
    include Ritsu::Utility::InstanceSet
    include Ritsu::Utility::Strings
    
    attr_reader :name
    attr_reader :dependency_targets
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
      @dependency_targets = Ritsu::Utility::CheckUponAddSet.new do |s,target|
        validate_dependency_target(target)
      end
      @dependency_libraries = Set.new
      @project = options[:project]
      @src_files = Set.new
      @custom_commands = []
      @topological_order = 0
      
      Target.instances << self
      @project.targets << self
    end
    
    def validate_dependency_target(target)
      if target == self
        raise ArgumentError.new("the given dependency is the same as the dependent target")
      end
      if !(target.kind_of? Target)
        raise ArgumentError.new("the given dependency target is not a kind of Ritsu::Target")
      end
      if depends_directly_on_target?(target)
        raise ArgumentError.new("'#{self.name}' already depends on '#{target.name}'")
      end
    end
    
    def can_be_depended_on?
      raise NotImplementedError.new
    end
    
    def self.validate_instance(instance)
      if instances.select { |x| x.name == instance.name }.length > 1
        raise "target with name '#{instance.name}' already exists"
      end
    end
    
    def depends_directly_on_target?(target)
      @dependency_targets.include? target
    end
    
    def depends_on_target?(target)
      visited = Set.new [self]
      queue = [self]
      
      # Perform a breadth first search
      while !visited.include?(target) && !queue.empty?
        u = queue.shift
        u.dependency_targets.each do |v|
          if !visited.include?(v)
            queue << v
            visited << v
          end
        end
      end
      
      visited.delete(self)
      visited.include?(target)
    end
    
    def src_dir
      self.name
    end
    
    def abs_dir
      File.expand_path(project.project_dir + "src/#{src_dir}")
    end
    
    def self.compute_topological_orders
      indegrees = {}
      instances.each { |target| indegrees[target] = 0 }
      instances.each do |target|
        target.dependency_targets.each do |dependency|
          indegrees[dependency] += 1
        end
      end
      
      last_order = instances.length-1
      indegree_zero = instances.select { |target| indegrees[target] == 0 }
      while !indegree_zero.empty?
        u = indegree_zero.shift
        u.topological_order = last_order
        last_order -= 1
        u.dependency_targets.each do |v|
          indegrees[v] -= 1
          if indegrees[v] == 0
            indegree_zero << v
          end
        end
      end
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
    
    def add_external_library(name)
      external_library = Ritsu::ExternalLibrary.find(name.to_s)
      if !external_library.nil?
        dependency_libraries << external_library
      else
        raise ArgumentError.new("no external library with name '#{name}'")
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
    
    def add_dependency_target(name)
      dependency = Target.find_by_name(name)
      if !dependency.nil?
        dependency_targets << dependency
        dependency.dependency_libraries.each do |library|
          dependency_libraries << library
        end
      else
        raise ArgumentError.new("no target with name '#{name}'")
      end
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