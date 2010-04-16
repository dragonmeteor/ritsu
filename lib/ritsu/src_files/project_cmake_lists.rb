require 'ritsu/src_file'
require 'ritsu/project'
require 'ritsu/target'
require 'ritsu/utility/instance_set'
require 'ritsu/utility/file_robot'
require 'ritsu/block'
require 'ritsu/template'
require 'ritsu/template_policies'
require 'ritsu/src_files/templated_src_file'

module Ritsu::SrcFiles
  class ProjectCmakeLists < Ritsu::SrcFiles::TemplatedSrcFile
    HEADER_ID = "ProjectCmakeLists -- Header"
    EXTERNAL_LIBRARIES_ID = "ProjectCmakeLists -- External Libraries"
    DIRECTORIES_ID = "ProjectCmakeLists -- Directories"
    
    class HeaderTemplate < Ritsu::Template
      def initialize(project)
        super(HEADER_ID)
        @project = project
      end
      
      def update_block(block, options={})
        block.contents.clear
        block.contents << "PROJECT(#{@project.name})"
        block.contents << "CMAKE_MINIMUM_REQUIRED(VERSION 2.6)"
        block.contents << "SET(CMAKE_MODULE_PATH \"${CMAKE_SOURCE_DIR}/cmake_modules\" ${CMAKE_MODULE_PATH})"
      end
    end
    
    class ExternalLibrariesTemplate < Ritsu::Template
      def initialize(project)
        super(EXTERNAL_LIBRARIES_ID)
        @project = project
      end
      
      def update_block(block, options={})
        block.contents.clear
        external_libraries = @project.external_libraries.to_a
        external_libraries.sort! {|x,y| x.name <=> y.name}
        external_libraries.each do |external_library|
          block.contents << external_library.cmake_find_script
        end        
      end
    end
    
    class DirectoriesTemplate < Ritsu::Template
      def initialize(project)
        super(DIRECTORIES_ID)
        @project = project
      end
      
      def update_block(block, options={})
        block.contents.clear
        @project.targets_sorted_by_topological_order.each do |target|
          block.contents << "ADD_SUBDIRECTORY(#{target.name})"
        end
      end
    end
    
    class Template < Ritsu::Template
      include Ritsu::TemplatePolicies::StrictBlockMatchingButLeaveUserTextBe
      
      def initialize(project)
        super
        @project = project
        contents << HeaderTemplate.new(project)
        contents << ""
        contents << ExternalLibrariesTemplate.new(project)
        contents << ""
        contents << DirectoriesTemplate.new(project)
      end
    end
    
    def initialize(owner = Ritsu::Project.instance)
      super('CMakeLists.txt', owner,
        :block_start_prefix => "##<<",
        :block_end_prefix => "##>>")
      self.template = Template.new(project)
    end
    
    def include_in_cmake?
      false
    end
  end
end