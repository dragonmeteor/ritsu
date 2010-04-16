require 'active_support/core_ext/string/starts_ends_with'
require 'ritsu/utility/check_upon_add_set'
require 'ritsu/utility/files'

module Ritsu
  class Block    
    attr_reader :id
    attr_accessor :contents
    attr_reader :block_start_prefix
    attr_reader :block_end_prefix
    attr_reader :block_content_prefix
        
    def initialize(id = nil, contents=[], options={})
      options = {
        :block_start_prefix => "//<<",
        :block_end_prefix => "//>>"
      }.merge(options)
      
      @id = id
      @contents = contents
      @block_start_prefix = options[:block_start_prefix]
      @block_end_prefix = options[:block_end_prefix]
      @block_content_prefix = options[:block_content_prefix]
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
      lines.each do |line|
        if line.strip.starts_with?(block_start_prefix)
          id = extract_block_id(line, block_start_prefix)
          block = Block.new(id, [], options)
          block_stack.last.contents << block
          block_stack.push(block)
        elsif line.strip.starts_with?(block_end_prefix)
          id = extract_block_id(line, block_end_prefix)
          if block_stack.last.id == id
            block_stack.pop()
          else
            block_stack.last.contents << line
          end
        else
          block_stack.last.contents << line
        end
      end
      
      if block_stack.length != 1
        raise ArgumentError.new("error in input. some blocks are malformed")
      end
    end

    def parse_string(string, options={})
      lines = string.split("\n")
      parse_lines(lines, options)
    end
    
    def parse_file(filename, options={})
      text = Ritsu::Utility::Files.read(filename)
      parse_string(text, options)
    end
    
    ##
    # In all case, the generated string shall have no trailing whitespaces.
    def to_s(options={})
      options = {:no_delimiter => false}.merge(options)
      
      io = StringIO.new
      io << block_start_prefix + " " + id + "\n" unless options[:no_delimiter]
      contents.each do |content|
        io << content.to_s + "\n"
      end
      io << block_end_prefix + " " + id unless options[:no_delimiter]
      
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
    #   -1 if there is no such child block.
    def child_block_with_id_position(id)
      contents.length.times do |i|
        if contents[i].kind_of?(Block) and contents[i].id == id
          return i
        end
      end
      return -1
    end
  end
end