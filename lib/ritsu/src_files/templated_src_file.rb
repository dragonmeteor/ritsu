require 'ritsu/src_file'
require 'ritsu/utility/file_robot'
require 'ritsu/block'
require 'ritsu/utility/files'

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
      Ritsu::Utility::FileRobot.create_file(abs_path, block.to_s(:no_delimiter=>true))
    end
    
    def update_content
      file_content = Ritsu::Utility::Files.read(abs_path)
      block = Ritsu::Block.parse(file_content, 
        :block_start_prefix => block_start_prefix,
        :block_end_prefix => block_end_prefix)
      template.update_block(block)
      
      new_content = block.to_s(:no_delimiter=>true)
      if new_content != file_content
        Ritsu::Utility::FileRobot.create_file(abs_path, new_content)
      end
    end
  end
end