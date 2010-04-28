require File.dirname(__FILE__) + '/../src_file'
require File.dirname(__FILE__) + '/../utility/file_robot'
require File.dirname(__FILE__) + '/../block'
require File.dirname(__FILE__) + '/../utility/files'

module Ritsu::SrcFiles
  class TemplatedSrcFile < Ritsu::SrcFile
    attr_accessor :template
    attr_accessor :block_start_prefix
    attr_accessor :block_end_prefix
    
    def initialize(src_path, owner, options={})
      super(src_path, owner)
      
      options = {
        :block_start_prefix => "//<<", 
        :block_end_prefix => "//>>"
      }.merge(options)
      @block_start_prefix = options[:block_start_prefix]
      @block_end_prefix = options[:block_end_prefix]
    end
    
    def create
      block = template.create_block( 
        :block_start_prefix => block_start_prefix,
        :block_end_prefix => block_end_prefix)
      template.update_block(block)
      Ritsu::Utility::FileRobot.create_file(abs_path, block.to_s(:no_delimiter=>true) + "\n")
    end
    
    def update_content
      file_content = Ritsu::Utility::Files.read(abs_path)
      block = Ritsu::Block.parse(file_content, 
        :block_start_prefix => block_start_prefix,
        :block_end_prefix => block_end_prefix)
      template.update_block(block)
      
      new_content = block.to_s(:no_delimiter=>true) + "\n"
      if new_content != file_content
        Ritsu::Utility::FileRobot.create_file(abs_path, new_content)
      end
    end
  end
end