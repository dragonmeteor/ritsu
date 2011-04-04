require 'rubygems'
require 'active_support'
require File.expand_path(File.dirname(__FILE__) + '/external_library')
require File.expand_path(File.dirname(__FILE__) + '/utility/single_instance')
require File.expand_path(File.dirname(__FILE__) + '/utility/strings')
require File.expand_path(File.dirname(__FILE__) + '/src_files/project_cmake_lists')
require File.expand_path(File.dirname(__FILE__) + '/src_files/project_config_header_file')
require File.expand_path(File.dirname(__FILE__) + '/src_files/project_config_header_template_file')
require File.expand_path(File.dirname(__FILE__) + "/utility/accessors")

module Ritsu
  class Project
    include Ritsu::Utility::SingleInstance
    include Ritsu::Utility::Strings
    include Ritsu::Utility::Accessors
    
    attr_reader :name
    attr_reader :targets
    attr_reader :external_libraries
    attr_reader :src_files
    attr_accessor :project_dir
    attr_reader :cmake_lists
    attr_reader :config_header_file
    attr_reader :config_header_template_file
    attr_accessor :custom_script
    attr_method :custom_script
    
    def initialize_instance(name)
      if !is_c_name?(name)
        raise ArgumentError.new(
          "the project name must be a valid C name")
      end
      
      @name = name
      @targets = Set.new
      @external_libraries = Set.new
      @src_files = Set.new
      @project_dir = File.expand_path('.')
      @custom_script = ""
      
      @cmake_lists = Ritsu::SrcFiles::ProjectCmakeLists.new(self)
      @config_header_file = Ritsu::SrcFiles::ProjectConfigHeaderFile.new(self)
      @config_header_template_file = Ritsu::SrcFiles::ProjectConfigHeaderTemplateFile.new(self)
    end
    
    def self.create(name)
      project = Project.new(name)
      yield project if block_given?
      project
    end
    
    def add_external_library(name)
      library = ExternalLibrary.new(name)
      yield library if block_given?
      @external_libraries << library
    end
    
    def project
      self
    end
    
    def src_dir
      project_dir + "/src"
    end
    
    def compute_src_path(path, options={})
      options = {:relative_to => :src}.merge(options)
      case options[:reltavie_to]
      when :src
        path
      when :absolute
        src_dir = Pathname.new(self.src_dir)
        input_path = Pathname.new(path)
        input_path.relative_path_from(src_dir).to_s
      else
        raise ArgumentError.new("option :relative_to must be either :src or :absolute")
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
      targets.each do |target|
        target.update
      end
    end
  end
end