require 'rubygems'
require 'active_support/core_ext/string/starts_ends_with'
require File.expand_path(File.dirname(__FILE__) + '/../../../src_files/target_cmake_lists')

module Ritsu
  module SrcFiles
    class TargetCmakeLists
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
          
          block.add_line "CUDA_COMPILE(#{cuda_generate_files_var_name}"
          block.indent
          cu_files.each do |cu_file|
            block.add_line("${CMAKE_SOURCE_DIR}/#{cu_file.src_path}")
          end
          block.outdent
          #if target.static_library?
          #  block.add_line("STATIC")
          #elsif target.shared_library?
          #  block.add_line("SHARED")
          #end
          block.add_line ")"
          block.add_new_line
          block.add_line "SET(#{target.name.upcase}_SRC_FILES ${#{target.name.upcase}_SRC_FILES} ${#{cuda_generate_files_var_name}})"
        end
      end
            
      class Template
        attr_reader :cuda_compile_template
        
        alias_method :initialize_before_cuda, :initialize
        
        def initialize(target, id = nil)
          initialize_before_cuda(target, id)
          
          @cuda_compile_template = CudaCompileTemplate.new(target)
          position = child_template_with_id_position(source_files_template.id) + 1
          contents.insert(position, @cuda_compile_template)
          contents.insert(position, "")
        end
        
        alias_method :position_to_insert_before_cuda, :position_to_insert
        
        def position_to_insert(block, new_block)
          if new_block.id == cuda_compile_template.id
              block.child_block_with_id_position(source_files_template.id) + 1
          else
            position_to_insert_before_cuda(block, new_block)
          end
        end
      end
    end
  end
end