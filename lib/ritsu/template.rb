require File.dirname(__FILE__) + '/block'

module Ritsu
  class Template
    include BlockMixin 
    
    def initialize(id = nil, options = {})
      initialize_block_mixin(id, options)
    end
    
    ##
    # @return (Template) the first child template with the given ID. 
    #   nil if there is no such child template.
    def child_template_with_id(id)
      contents.each do |content|
        if content.kind_of?(Template) and content.id == id
          return content
        end
      end
      return nil
    end
    
    ##
    # @return (Template) the position of the child template with the given ID in the contents array. 
    #   nil if there is no such child template.
    def child_template_with_id_position(id)
      contents.length.times do |i|
        if contents[i].kind_of?(Template) and contents[i].id == id
          return i
        end
      end
      return nil
    end
    
    def child_templates
      contents.select {|x| x.kind_of?(Template)}
    end
    
    def create_block(options={})
      options = {}.merge(options)
      options[:local_indentation] = local_indentation
      block = Block.new(id, options)
      contents.each do |content|
        if !content.kind_of?(Template)
          block.contents << content
        else
          block.contents << content.create_block(options)
        end
      end
      block
    end
    
    def update_block(block, options={})
      raise NotImplmentedError.new
    end
    
    def add_template(template)
      add_block_structure(template)
    end
    
    def add_content(content)
      if content.kind_of?(Template)
        add_template(content)
      else
        add_line_or_other_content(content)
      end
    end
  end
end