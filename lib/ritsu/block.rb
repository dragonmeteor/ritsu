require 'rubygems'
require 'active_support/core_ext/string/starts_ends_with'
require File.dirname(__FILE__) + '/utility/check_upon_add_set'
require File.dirname(__FILE__) + '/utility/files'
require File.dirname(__FILE__) + '/utility/strings'

module Ritsu
  module BlockMixin
    attr_reader :id
    attr_accessor :contents
    attr_accessor :local_indentation
    attr_accessor :indent_level
    attr_accessor :indent_length
    
    def initialize_block_mixin(id = nil, options={})
      options = {
        :contents => [],
        :local_indentation => "", 
        :indent_length=>4
      }.merge(options)
      
      @id = id
      @contents = options[:contents]
      @local_indentation = options[:local_indentation]
      @indent_length = options[:indent_length]
      @indent_level = 0
    end
    
    def add_line(line)
      contents << " " * (indent_level * indent_length) + line
    end
    
    def add_new_line
      add_line("")
    end
    
    protected
    def add_block_structure(block)
      block.local_indentation = block.local_indentation + " " * (indent_level * indent_length)
      contents << block
    end
    
    def add_line_or_other_content(content)
      if content.kind_of?(String)
        add_line(content)
      else
        contents << content
      end
    end
    
    public
    def clear_contents
      contents.clear
    end
    
    def indent
      @indent_level += 1
    end
    
    def outdent
      @indent_level -= 1
    end
    
    def block_structure?
      true
    end
  end
  
  class Block
    include BlockMixin
    
    attr_accessor :block_start_prefix
    attr_accessor :block_end_prefix
        
    def initialize(id = nil, options={})
      options = {
        :block_start_prefix => "//<<",
        :block_end_prefix => "//>>"
      }.merge(options)

      @block_start_prefix = options[:block_start_prefix]
      @block_end_prefix = options[:block_end_prefix]
      
      initialize_block_mixin(id, options)
    end
    
    def self.extract_block_id(str, prefix)
      str.strip.slice((prefix.length)..-1).strip
    end
    
    def extract_block_id(str, prefix)
      Block.extract_block_id(str, prefix)
    end
    
    def parse_lines(lines, options={})
      options = {
        :block_start_prefix => block_start_prefix,
        :block_end_prefix => block_end_prefix
      }.merge(options)
      @block_start_prefix = options[:block_start_prefix]
      @block_end_prefix = options[:block_end_prefix]
      
      block_stack = [self]
      global_indentation_length = 0
      
      get_local_indentation = Proc.new do |line|
        leading_spaces_length = Ritsu::Utility::Strings.leading_spaces(line, options).length
        remaining_space_length = leading_spaces_length - global_indentation_length
        if remaining_space_length < 0 then remaining_space_length = 0 end
        " " * remaining_space_length
      end
      
      append_line = Proc.new do |line|
        block_stack.last.contents << (get_local_indentation.call(line) + line.lstrip)
      end
      
      lines.each do |line|
        if line.strip.starts_with?(block_start_prefix)
          id = extract_block_id(line, block_start_prefix)
          local_indentation = get_local_indentation.call(line)
          
          options[:local_indentation] = local_indentation
          block = Block.new(id, options)
          block_stack.last.contents << block
          block_stack.push(block)
          global_indentation_length += block.local_indentation.length
        elsif line.strip.starts_with?(block_end_prefix)
          id = extract_block_id(line, block_end_prefix)
          if block_stack.last.id == id
            block = block_stack.pop()
            global_indentation_length -= block.local_indentation.length
          else
            append_line.call(line)
          end
        else
          append_line.call(line)
        end
      end
      
      if block_stack.length != 1
        raise ArgumentError.new("error in input. some blocks are malformed")
      end
    end

    def parse_string(string, options={})
      lines = string.rstrip.split("\n")
      parse_lines(lines, options)
    end
    
    def parse_file(filename, options={})
      text = Ritsu::Utility::Files.read(filename)
      parse_string(text, options)
    end
    
    ##
    # In all case, the generated string shall have no trailing whitespaces.
    def to_s(options={})
      options = {:no_delimiter => false, :indentation => ""}.merge(options)
      no_delimiter = options.delete(:no_delimiter)
      indentation = options.delete(:indentation)
      
      io = StringIO.new
      io << indentation + local_indentation + block_start_prefix + " " + id + "\n" unless no_delimiter
      contents.each do |content|
        if content.kind_of?(Block)
          io << content.to_s({:indentation=>indentation+local_indentation}.merge(options)) + "\n"
        else
          io << indentation + local_indentation + content.to_s + "\n"
        end
      end
      io << indentation + local_indentation + block_end_prefix + " " + id unless no_delimiter
      
      io.string.rstrip
    end
    
    def write_to_file(filename, options={})
      options = {:no_delimiter => true}.merge(options)
      
      File.open(filename, "w") do |f|
        f.write(to_s(options))
      end
    end
    
    def self.parse(*args)
      if args.length > 2
        raise ArgumentError.new("only at most 2 arguments, the second one is a hash, are accepted")
      end
      options = {}
      
      prepare_options_from_kth_arg = Proc.new do |k|
        options = options.merge(args[k]) if (args.length > k)
      end
      
      block = Block.new
      result = case args[0]
      when Array
        prepare_options_from_kth_arg.call(1)
        block.parse_lines(args[0], options)
      when String
        prepare_options_from_kth_arg.call(1)
        block.parse_string(args[0], options)
      when Hash
        if filename = args[0].delete(:file)
          prepare_options_from_kth_arg.call(0)
          block.parse_file(filename, options)
        else
          raise ArgumentError.new("you must specify :file option if the first argument is a hash")
        end
      end
      return block
    end
    
    def child_block_count
      count = 0
      contents.each do |content|
        count += 1 if content.kind_of?(Block)
      end
    end
    
    ##
    # @return (Block) the first child block with the given ID. nil if there is no such child block.
    def child_block_with_id(id)
      contents.each do |content|
        if content.kind_of?(Block) and content.id == id
          return content
        end
      end
      return nil
    end
    
    def child_blocks
      contents.select {|x| x.kind_of?(Block)}
    end
    
    ##
    # @return (Integer) the position of the child block with the given ID in the contents array. 
    #   nil if there is no such child block.
    def child_block_with_id_position(id)
      contents.length.times do |i|
        if contents[i].kind_of?(Block) and contents[i].id == id
          return i
        end
      end
      return nil
    end
    
    def add_block(block)
      add_block_structure(block)
    end
    
    def add_content(content)
      if content.kind_of?(Block)
        add_block(content)
      else
        add_line_or_other_content(content)
      end
    end
  end
end