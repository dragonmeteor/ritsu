require 'ritsu/src_files/target_cmake_lists'

module Ritsu::SrcFiles
  class StaticLibraryCmakeLists < TargetCmakeLists
    class StaticLibraryTemplate < Ritsu::Template
      attr_accessor :target
      attr_accessor :parent 
      
      def initialize(target, parent)
        super("StaticLibraryCmakeLists -- #{target.name} -- Static Library")
        @target = target
        @parent = parent
      end
      
      def update_block(block, options={})
        block.contents.clear
        block.contents << "ADD_LIBRARY(#{@target.name} STATIC ${#{@parent.source_files_template.src_files_var_name}})"
      end
    end
    
    class Template < Ritsu::SrcFiles::TargetCmakeLists::Template
      def initialize(target, options={})
        super(target, "StaticLibraryCmakeLists -- #{target.name}")
        
        position_to_insert = contents.index(dependencies_template)
        contents.insert(position_to_insert, StaticLibraryTemplate.new(target, self))
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