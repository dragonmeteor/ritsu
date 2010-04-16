require 'rubygems'
require 'ritsu/project_generator'
require 'ritsu/utility/file_robot'
require 'ritsu/utility/files'
require 'singleton'
require 'erb'
require 'active_support/core_ext/string/inflections'

module Ritsu::ProjectGenerators
  class DefaultGenerator < Ritsu::ProjectGenerator
    include Singleton
    include Ritsu::Utility
    
    def initialize
      super("default")
    end
    
    def source_dir
      File.dirname(__FILE__) + "/default_generator_files"
    end
    
    def source_path(path)
      source_dir + "/" + path
    end
    
    def target_dir
      return @location + "/" + @project_name
    end
    
    def target_path(path)
      target_dir + "/" + path
    end
    
    def create_dir(dirname)
      FileRobot.create_dir(target_path(dirname))
    end
    
    def create_file(filename, content)
      FileRobot.create_file(target_path(filename), content)
    end
    
    def create_file_from_erb(filename)
      template_filename = source_path(filename + ".erb")
      template_content = Files.read(template_filename)
      template = ERB.new(template_content)
      create_file(filename, template.result(binding))
    end
    
    def copy_file(filename)
      source_filename = source_path(filename)
      source_content = Files.read(source_filename)
      create_file(filename, source_content)
    end
    
    def generate(project_name, location, options={})
      @location = File.expand_path(location)
      @project_name = project_name
      
      create_dir("")
      
      create_dir("build")
      create_dir("")
      create_dir("meta")
      create_dir("src")
      create_dir("src/cmake_modules")
      
      create_file_from_erb("Thorfile")
      create_file_from_erb("meta/project.rb")
    end
  end
  
  DefaultGenerator.instance
end