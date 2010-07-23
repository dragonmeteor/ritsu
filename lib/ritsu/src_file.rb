require 'rubygems'
require 'active_support'
require File.expand_path(File.dirname(__FILE__) + '/utility/instance_set')
require File.expand_path(File.dirname(__FILE__) + '/utility/file_robot')

module Ritsu
  class SrcFile
    include Ritsu::Utility::InstanceSet
    include Ritsu::Utility
    
    attr_reader :src_path
    attr_reader :owner
    
    def self.is_valid_src_path?(p)
      p =~ /^[A-Za-z0-9_.][A-Za-z0-9_.\-\/]*$/
    end
        
    def initialize(src_path, owner)
      if !(self.class.is_valid_src_path?(src_path))
        raise ArgumentError.new "'#{src_path}' is not a valid source path"
      end

      @src_path = src_path
      @owner = owner
      
      SrcFile.instances << self
      @owner.src_files << self
    end
    
    def base_name
      File.basename(src_path)
    end
    
    def self.validate_instance(instance)
      if instances.select { |x| x.src_path == instance.src_path }.length > 0
        raise ArgumentError.new "source file with path '#{instance.src_path}' already exists"
      end
    end
    
    def project
      owner.project
    end
    
    def abs_path
      File.expand_path(project.project_dir + "/src/" + src_path)
    end
    
    def create
      FileRobot.create_file(abs_path, "\n")
    end
    
    def update
      if !File.exists?(abs_path)
        create
      else
        update_content
      end
    end
    
    def update_content
    end
    
    def remove
      FileRobot.remove_file(abs_path)
    end
    
    def include_in_source_files?
      return true
    end
    
    def self.find_by_src_path(src_path)
      instances.each do |instance|
        if instance.src_path == src_path
          return instance
        end
      end
      nil
    end
  end
end