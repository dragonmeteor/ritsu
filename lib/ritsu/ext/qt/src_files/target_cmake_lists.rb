require 'rubygems'
require 'active_support/core_ext/string/starts_ends_with'
require File.expand_path(File.dirname(__FILE__) + '/../../../src_files/target_cmake_lists')

module Ritsu
  module SrcFiles
    class TargetCmakeLists
      class QtUiTemplate < Ritsu::Template
        attr_reader :target
        
        def initialize(target)
          super("TargetCmakeLists -- #{target.name} -- QtUi")
          @target = target
        end
        
        def ui_header_files_var_name
          "#{target.name.upcase}_UI_HEADER_FILES"
        end
      
        def update_block(block, options = {})
          block.clear_contents
          
          ui_files = target.src_files.select { |x| x.respond_to?(:ui_file?) && x.ui_file? }
          if ui_files.length == 0
            return
          end
          ui_files.sort! {|x,y| x.src_path <=> y.src_path}
          
          block.add_line "RITSU_QT4_WRAP_UI(#{ui_header_files_var_name}"
          block.indent
          ui_files.each do |ui_file|
            block.add_line("${CMAKE_SOURCE_DIR}/#{ui_file.src_path}")
          end
          block.outdent
          block.add_line ")"
          block.add_new_line
          block.add_line "SET(#{target.name.upcase}_SRC_FILES ${#{target.name.upcase}_SRC_FILES} ${#{ui_header_files_var_name}})"
        end
      end
      
      class QtMocTemplate < Ritsu::Template
        attr_reader :target
        
        def initialize(target)
          super("TargetCmakeLists -- #{target.name} -- QtMoc")
          @target = target
        end
        
        def moc_src_files_var_name
          "#{target.name.upcase}_MOC_SRC_FILES"
        end
        
        def update_block(block, options = {})
          block.clear_contents
          
          header_files = target.src_files.select { |x| x.respond_to?(:qt_header_file?) && x.qt_header_file? }
          if header_files.length == 0
            return
          end
          header_files.sort! {|x,y| x.src_path <=> y.src_path}
          
          block.add_line "QT4_WRAP_CPP(#{moc_src_files_var_name}"
          block.indent
          header_files.each do |header_file|
            block.add_line("${CMAKE_SOURCE_DIR}/#{header_file.src_path}")
          end
          block.outdent
          block.add_line ")"
          block.add_new_line
          block.add_line "SET(#{target.name.upcase}_SRC_FILES ${#{target.name.upcase}_SRC_FILES} ${#{moc_src_files_var_name}})"
        end
      end
      
      class Template
        attr_reader :qt_ui_template
        attr_reader :qt_moc_template
        
        alias_method :initialize_before_qt, :initialize
        
        def initialize(target, id = nil)
          initialize_before_qt(target, id)
          
          @qt_ui_template = QtUiTemplate.new(target)
          @qt_moc_template = QtMocTemplate.new(target)
          
          position = child_template_with_id_position(source_files_template.id) + 1
          contents.insert(position, @qt_moc_template)
          contents.insert(position, "")
          contents.insert(position, @qt_ui_template)
          contents.insert(position, "")
        end
        
        alias_method :position_to_insert_before_qt, :position_to_insert
        
        def position_to_insert(block, new_block)
          if new_block.id == qt_moc_template.id
            block.child_block_with_id_position(qt_ui_template.id) + 2
          elsif new_block.id == qt_ui_template.id
            block.child_block_with_id_position(source_files_template.id) + 2
          else
            position_to_insert_before_cuda(block, new_block)
          end
        end
      end
    end
  end
end