require File.dirname(__FILE__) + '/block'

module Ritsu
  class Template
    attr_reader :id
    attr_accessor :contents
    
    def initialize(id = nil, contents=[])
      @id = id
      @contents = contents
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
    #   -1 if there is no such child template.
    def child_template_with_id_position(id)
      contents.length.times do |i|
        if contents[i].kind_of?(Template) and contents[i].id == id
          return i
        end
      end
      return -1
    end
    
    def child_templates
      contents.select {|x| x.kind_of?(Template)}
    end
    
    def create_block(options={})
      block = Block.new(id, [], options)
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
  end  
end