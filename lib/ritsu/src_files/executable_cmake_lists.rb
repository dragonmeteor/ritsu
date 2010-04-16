require 'ritsu/src_files/target_cmake_lists'

module Ritsu::SrcFiles
  class ExecutableCmakeLists < TargetCmakeLists
    class ExecutableTemplate < Ritsu::Template
      attr_accessor :target
      attr_accessor :parent 
      
      def initialize(target, parent)
        super("ExecutableCmakeLists -- #{target.name} -- Executable")
        @target = target
        @parent = parent
      end
      
      def update_block(block, options={})
        block.contents.clear
        block.contents << "ADD_EXECUTABLE(#{@target.name} ${#{@parent.source_files_template.src_files_var_name}})"
      end
    end
    
    class Template < Ritsu::SrcFiles::TargetCmakeLists::Template
      def initialize(target, options={})
        super(target, "ExecutableCmakeLists -- #{target.name}")
        
        position_to_insert = contents.index(dependencies_template)
        contents.insert(position_to_insert, ExecutableTemplate.new(target, self))
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