require File.dirname(__FILE__) + '/../src_files/target_cmake_lists'

module Ritsu
  module SrcFiles
    class SharedLibraryCmakeLists < TargetCmakeLists
      class SharedLibraryTemplate < Ritsu::Template
        attr_accessor :target
        attr_accessor :parent 
      
        def initialize(target, parent)
          super("SharedLibraryCmakeLists -- #{target.name} -- Shared Library")
          @target = target
          @parent = parent
        end
      
        def update_block(block, options={})
          block.contents.clear
          block.contents << "ADD_LIBRARY(#{@target.name} SHARED ${#{@parent.source_files_template.src_files_var_name}})"
        end
      end
    
      class Template < Ritsu::SrcFiles::TargetCmakeLists::Template
        def initialize(target, options={})
          super(target, "SharedLibraryCmakeLists -- #{target.name}")
        
          position_to_insert = contents.index(dependencies_template)
          contents.insert(position_to_insert, SharedLibraryTemplate.new(target, self))
          contents.insert(position_to_insert+1, "")
        end
      end
    
      def initialize(target)
        super(target)
        self.template = Template.new(target,
          :block_start_prefix => '##<<',
          :block_end_prefix => '##>>')
      end
    end
  end
end