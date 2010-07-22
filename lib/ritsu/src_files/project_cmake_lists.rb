require File.expand_path(File.dirname(__FILE__) + '/../template')
require File.expand_path(File.dirname(__FILE__) + '/../template_policies')
require File.expand_path(File.dirname(__FILE__) + '/../src_files/templated_src_file')

module Ritsu
  module SrcFiles
    class ProjectCmakeLists < Ritsu::SrcFiles::TemplatedSrcFile
      class HeaderTemplate < Ritsu::Template
        include Ritsu::TemplatePolicies::Overwrite
        
        def initialize(project)
          super("ProjectCmakeLists -- Header")
          @project = project
          
          add_line "PROJECT(#{@project.name})"
          add_line "CMAKE_MINIMUM_REQUIRED(VERSION 2.8)"
          add_line "SET(CMAKE_MODULE_PATH \"${CMAKE_SOURCE_DIR}/cmake_modules\" ${CMAKE_MODULE_PATH})"
          add_new_line
          add_line "IF(WIN32)"
          add_line '    OPTION(__WIN_PLATFORM__ "Windows Platform" ON)'
          add_line "ELSE(WIN32)"
          add_line '    OPTION(__WIN_PLATFORM__ "Windows Platform" OFF)'
          add_line "ENDIF(WIN32)"
          add_new_line
          add_line "IF(UNIX)"
          add_line "    IF(APPLE)"          
          add_line '        OPTION(__MAC_PLATFORM__ "Apple Platform" ON)'
          add_line '        OPTION(__UNIX_PLATFORM__ "Unix Platform" OFF)'
          add_line "    ELSE(APPLE)"
          add_line '        OPTION(__MAC_PLATFORM__ "Apple Platform" OFF)'
          add_line '        OPTION(__UNIX_PLATFORM__ "Unix Platform" ON)'
          add_line "    ENDIF(APPLE)"
          add_line "ELSE(UNIX)"
          add_line '    OPTION(__MAC_PLATFORM__ "Apple Platform" OFF)'
          add_line '    OPTION(__UNIX_PLATFORM__ "Unix Platform" OFF)'
          add_line "ENDIF(UNIX)"
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
      
      class ConfigureFileTemplate < Ritsu::Template
        include Ritsu::TemplatePolicies::Overwrite
        
        def initialize(project)
          super("ProjectCmakeLists -- Configure File")
          @project = project
          
          add_line "CONFIGURE_FILE( ${CMAKE_SOURCE_DIR}/config.h.in ${CMAKE_SOURCE_DIR}/config.h )"
        end
      end
    
      class Template < Ritsu::Template
        include Ritsu::TemplatePolicies::StrictBlockMatchingButLeaveUserTextBe
      
        def initialize(project)
          super
          @project = project
          
          add_template HeaderTemplate.new(project)
          add_new_line
          add_template ExternalLibrariesTemplate.new(project)
          add_new_line
          add_template DirectoriesTemplate.new(project)
          add_new_line
          add_template ConfigureFileTemplate.new(project)
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