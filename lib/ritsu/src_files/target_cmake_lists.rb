require File.dirname(__FILE__) + '/../src_file'
require File.dirname(__FILE__) + '/../utility/instance_set'
require File.dirname(__FILE__) + '/../template'
require File.dirname(__FILE__) + '/../template_policies'
require File.dirname(__FILE__) + '/../src_files/templated_src_file'

module Ritsu
  module SrcFiles
    class TargetCmakeLists < Ritsu::SrcFiles::TemplatedSrcFile
      class LibrariesTemplate < Ritsu::Template
        attr_accessor :target
      
        def initialize(target)
          super("TargetCmakeLists -- #{target.name} -- Libraries")
          @target = target
        end
      
        def update_block(block, options = {})
          external_libraries = target.dependency_libraries.to_a
          external_libraries.sort! {|x,y| x.name <=> y.name}
          
          dependency_targets = target.dependency_targets.to_a
          dependency_targets.sort! {|x,y| x.name <=> y.name}
        
          block.contents.clear
          external_libraries.each do |external_library|
            block.contents << external_library.cmake_depend_script
          end
          dependency_targets.each do |dependency_target|
            if dependency_target.cmake_depend_script.strip.length > 0
              block.contents << dependency_target.cmake_depend_script
            end
          end
          
          if target.library?
            if target.cmake_depend_script.strip.length > 0
              block.contents << target.cmake_depend_script
            end
          end
        end
      end
    
      class CustomCommandsTemplate < Ritsu::Template
        attr_accessor :target
      
        def initialize(target)
          super("TargetCmakeLists -- #{target.name} -- Custom Commands")
          @target = target
        end
      
        def update_block(block, options = {})
          block.contents.clear
          target.custom_commands.each do |custom_command|
            block.contents << custom_command.to_s
          end
        end
      end
    
      class SourceFilesTemplate < Ritsu::Template
        attr_accessor :target
      
        def initialize(target)
          super("TargetCmakeLists -- #{target.name} -- Source Files")
          @target = target
        end
      
        def src_files_var_name
          target.name.upcase + "_SRC_FILES"
        end
      
        def update_block(block, options = {})
          block.contents.clear
          block.contents << "SET(#{src_files_var_name}"
        
          src_files = target.src_files.to_a
          src_files.sort! {|x,y| x.src_path <=> y.src_path}
          src_files.each do |src_file|
            block.contents << "    ${CMAKE_SOURCE_DIR}/#{src_file.src_path}" if src_file.include_in_cmake?
          end
        
          block.contents << ")"
        end
      end
    
      class DependenciesTemplate < Ritsu::Template
        attr_reader :target
      
        def initialize(target)
          super("TargetCmakeLists -- #{target.name} -- Dependencies")
          @target = target
        end
      
        def update_block(block, options = {})
          block.contents.clear

          external_libraries = target.dependency_libraries.to_a
          external_libraries.sort! {|x,y| x.name <=> y.name}
          dependency_targets = target.dependency_targets.to_a
          dependency_targets.sort! {|x,y| x.name <=> y.name}
        
          if external_libraries.length == 0 && dependency_targets.length == 0
            return
          end

          block.contents << "TARGET_LINK_LIBRARIES(#{target.name}"
        
          external_libraries.each do |external_library|
            block.contents << "    " + external_library.cmake_name
          end
        
          dependency_targets.each do |dependency_target|
            block.contents << "    " + dependency_target.name
          end
        
          block.contents << ")"
        end
      end
    
      class Template < Ritsu::Template
        include Ritsu::TemplatePolicies::FlexibleBlockMatchingAndCreateMissingBlockButLeaveUserTextBe
        attr_reader :target
        attr_reader :libraries_template
        attr_reader :custom_commands_template
        attr_reader :source_files_template
        attr_reader :dependencies_template
      
        def initialize(target, id = nil)
          super(id)
          @target = target
        
          @libraries_template = LibrariesTemplate.new(@target)
          contents << @libraries_template
          contents << ""
        
          @custom_commands_template = CustomCommandsTemplate.new(@target)
          contents << @custom_commands_template
          contents << ""
        
          @source_files_template = SourceFilesTemplate.new(@target)
          contents << @source_files_template
          contents << ""
        
          @dependencies_template = DependenciesTemplate.new(@target)
          contents << @dependencies_template
        end
      end
    
      def initialize(target)
        super("#{target.name}/CMakeLists.txt", target,
          :block_start_prefix=>'##<<',
          :block_end_prefix=>'##>>')
      end
    
      def include_in_cmake?
        false
      end
    end
  end
end