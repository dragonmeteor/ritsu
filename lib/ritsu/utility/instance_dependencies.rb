require 'rubygems'
require 'active_support/core_ext/string/inflections'
require 'active_support/inflector'
require File.dirname(__FILE__) + "/instance_set"

module Ritsu
  module Utility
    module InstanceDependencies
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def dependencies_between(name)
          name = name.to_s.singularize
          dependency_set_name = "dependency_#{name.pluralize}"
          
          module_eval <<-RUBY
            attr_reader :#{dependency_set_name}
            attr_accessor :topological_order
            
            def #{dependency_set_name}
              @#{dependency_set_name} ||= Ritsu::Utility::CheckUponAddSet.new do |s,dependency|
                validate_dependency_#{name}(dependency)
                self.class.invalidate_topological_orders
              end
            end
            
            def depends_directly_on_#{name}?(instance)
              #{dependency_set_name}.include?(instance)
            end
            
            def depends_on_#{name}?(instance)
              visited = Set.new [self]
              queue = [self]

              # Perform a breadth first search
              while !visited.include?(instance) && !queue.empty?
                u = queue.shift
                u.#{dependency_set_name}.each do |v|
                  if !visited.include?(v)
                    queue << v
                    visited << v
                  end
                end
              end

              visited.delete(self)
              visited.include?(instance)
            end
            
            def validate_dependency_#{name}(instance)
              instance_name = instance.name
              if instance == self
                raise ArgumentError.new("'\#{instance.name}' is the same as the dependent #{name}")
              end
              if instance.depends_on_#{name}?(self)
                raise ArgumentError.new("including '\#{instance.name}' will create a circular dependency")
              end
              if !instance.can_be_depended_on?
                raise ArgumentError.new("'\#{instance.name}' cannot be dependend on")
              end
            end
            
            def self.recompute_topological_orders
              indegrees = {}
              instances.each { |instance| indegrees[instance] = 0 }
              instances.each do |instance|
                instance.#{dependency_set_name}.each do |dependency|
                  indegrees[dependency] += 1
                end
              end

              last_order = instances.length-1
              indegree_zero = instances.select { |instance| indegrees[instance] == 0 }
              while !indegree_zero.empty?
                u = indegree_zero.shift
                u.topological_order = last_order
                last_order -= 1
                u.#{dependency_set_name}.each do |v|
                  indegrees[v] -= 1
                  if indegrees[v] == 0
                    indegree_zero << v
                  end
                end
              end
              
              @topological_orders_computed = true
            end
            
            def self.topological_orders_computed?
              @topological_order_computed ||= false
            end

            def self.compute_topological_orders
              if !topological_orders_computed?
                recompute_topological_orders
              end
            end

            def self.invalidate_topological_orders
              @topological_order_computed = false
            end
            
            def can_be_depended_on?
              raise NotImplementedError.new
            end
          RUBY
        end
      end
    end
  end
end