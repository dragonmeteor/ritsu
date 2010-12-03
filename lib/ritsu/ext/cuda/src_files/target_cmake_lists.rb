require 'rubygems'
require 'active_support/core_ext/string/starts_ends_with'
require File.expand_path(File.dirname(__FILE__) + '/../../../src_files/target_cmake_lists')

module Ritsu
  module SrcFiles
    class TargetCmakeLists
      class CudaIncludeDirectoriesTemplate < Ritsu::Template
        attr_reader :target
        
        def initialize(target)
          super("TargetCmakeLists -- #{target.name} -- CudaIncludeDirectories")
          @target = target
        end
        
        def update_block(block, options = {})
          external_libraries = target.dependency_libraries.to_a
          external_libraries.sort! {|x,y| x.name <=> y.name}

          dependency_targets = target.dependency_targets.to_a
          dependency_targets.sort! {|x,y| x.name <=> y.name}

          block.contents.clear
          external_libraries.each do |external_library|
            if external_library.cuda_depend_script.strip.length > 0
              block.contents << external_library.cuda_depend_script
            end
          end
          dependency_targets.each do |dependency_target|
            if dependency_target.cuda_depend_script.strip.length > 0
              block.contents << dependency_target.cuda_depend_script
            end
          end

          if target.library?
            if target.cuda_depend_script.strip.length > 0
              block.contents << target.cuda_depend_script
            end
          end
        end
      end
      
      class CudaCompileTemplate < Ritsu::Template
        attr_reader :target
      
        def initialize(target)
          super("TargetCmakeLists -- #{target.name} -- CudaCompile")
          @target = target
        end
        
        def cuda_generate_files_var_name
          "#{target.name.upcase}_CUDA_GENERATED_FILES"
        end
      
        def update_block(block, options = {})
          block.clear_contents
          
          cu_files = target.src_files.select { |x| x.respond_to?(:cu_file?) && x.cu_file? }
          if cu_files.length == 0
            return
          end
          cu_files.sort! {|x,y| x.src_path <=> y.src_path}
          
          block.add_line "CUDA_COMPILE(#{cuda_generate_files_var_name}"
          block.indent
          cu_files.each do |cu_file|
            block.add_line("${CMAKE_SOURCE_DIR}/#{cu_file.src_path}")
          end
          block.outdent
          block.add_line ")"
          block.add_new_line
          block.add_line "SET(#{target.name.upcase}_SRC_FILES ${#{target.name.upcase}_SRC_FILES} ${#{cuda_generate_files_var_name}})"
        end
      end
            
      class Template
        attr_reader :cuda_compile_template
        attr_reader :cuda_include_directories_template
        
        alias_method :initialize_before_cuda, :initialize
        
        def initialize(target, id = nil)
          initialize_before_cuda(target, id)
          
          @cuda_include_directories_template = CudaIncludeDirectoriesTemplate.new(target)
          @cuda_compile_template = CudaCompileTemplate.new(target)
          
          if target.cuda_target?
            position = child_template_with_id_position(libraries_template.id) + 1
            contents.insert(position, @cuda_include_directories_template)
            contents.insert(position, "")
          
            position = child_template_with_id_position(source_files_template.id) + 1
            contents.insert(position, @cuda_compile_template)
            contents.insert(position, "")
          end
        end
        
        alias_method :position_to_insert_before_cuda, :position_to_insert
        
        def position_to_insert(block, new_block)
          if new_block.id == cuda_compile_template.id
              block.child_block_with_id_position(source_files_template.id) + 2
          else
            position_to_insert_before_cuda(block, new_block)
          end
        end
      end
    end
  end
end