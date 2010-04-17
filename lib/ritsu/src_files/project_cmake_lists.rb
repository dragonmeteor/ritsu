require File.dirname(__FILE__) + '/../template'
require File.dirname(__FILE__) + '/../template_policies'
require File.dirname(__FILE__) + '/../src_files/templated_src_file'

module Ritsu
  module SrcFiles
    class ProjectCmakeLists < Ritsu::SrcFiles::TemplatedSrcFile
      class HeaderTemplate < Ritsu::Template
        def initialize(project)
          super("ProjectCmakeLists -- Header")
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
          super("ProjectCmakeLists -- External Libraries")
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
          super("ProjectCmakeLists -- Directories")
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
    
      def initialize(owner)
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
end