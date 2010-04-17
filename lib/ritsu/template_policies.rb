require File.dirname(__FILE__) + '/template'

module Ritsu::TemplatePolicies
  module StrictBlockMatchingButLeaveUserTextBe
    def update_block(block, options={})
      child_blocks = block.child_blocks
      index = 0
      child_templates.each do |child_template|
        while index < child_blocks.length && child_blocks[index].id != child_template.id
          index += 1
        end
        if index >= child_blocks.length
          if child_blocks.select {|x| x.id == child_template.id}
            raise ArgumentError.new("block with id '#{child_template.id}' appears out of order")
          else
            raise ArgumentError.new("cannot find block with id '#{child_template.id}'")
          end
        end
        child_template.update_block(child_blocks[index])
        index += 1
      end
    end
  end
  
  module FlexibleBlockMatching
    ##
    # @param (Block) a block
    # @return (Hash) a hash mapping each child template to a child block with the same id.
    #   If there is no such child block, the child template is mapped to nil.
    def match_child_blocks(block)
      child_blocks = block.child_blocks
      matching_child_blocks = {}
      child_templates.each do |child_template|
        matching = nil
        child_blocks.each do |child_block|
          if child_template.id == child_block.id
            matching = child_block
            break
          end
        end
        child_blocks.delete(matching) unless matching.nil?
        matching_child_blocks[child_template] = matching
      end
      matching_child_blocks
    end
  end
  
  module FlexibleBlockMatchingAndCreateMissingBlocksButIgnoreUserText
    include FlexibleBlockMatching
    
    def update_block(block, options={})
      matching_child_blocks = match_child_blocks(block)
      
      block.contents.clear
      contents.each do |content|
        if content.kind_of?(Template)
          if matching_child_blocks[content].nil?
            block.contents << content.create_block(options)
          else
            matching = matching_child_blocks[content]
            content.update_block(matching)
            block.contents << matching
          end
        else
          block.contents << content
        end
      end
    end
  end
  
  module FlexibleBlockMatchingAndCreateMissingBlockButLeaveUserTextBe
    include FlexibleBlockMatching
    
    def update_block(block, options={})
      matching_child_blocks = match_child_blocks(block)
      
      child_templates.each do |child_template|
        if matching_child_blocks[child_template].nil?
          new_block = child_template.create_block(options)
          block.contents.insert(
            position_to_insert(block, new_block),
            new_block)
        else
          matching = matching_child_blocks[child_template]
          child_template.update_block(matching)
        end
      end
    end
    
    ##
    # @return (Integer) the position in block.contents to
    #  insert the given new block
    def position_to_insert(block, new_block)
      raise NotImplmentedError
    end
  end
end