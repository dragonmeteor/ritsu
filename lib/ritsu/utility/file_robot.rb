require 'fileutils'
require 'singleton'
require 'ritsu/utility/simple_io'

module Ritsu::Utility
  class FileRobot
    include Singleton
    def self.v; instance end
    
    def self.method_missing(symbol, *args, &block)
      instance.send(symbol, *args, &block)
    end
    
    attr_accessor :force
    attr_reader :io
    
    def initialize
      @io = SimpleIO.new
      @force = false
    end
    
    def output; io.output end
    def output=(value); io.output = value end
    def input; io.input end
    def input=(value); io.input = value end
    def quiet; io.quiet end
    def quiet=(value); io.quiet = value end
    
    def quietly(&block)
      old_quiet = self.quiet
      self.quiet = true
      block.call
      self.quiet = old_quiet
    end
    
    def verbosely(&block)
      old_quiet = self.quiet
      self.quiet = false
      block.call
      self.quiet = old_quiet
    end
    
    def forcefully(&block)
      old_force = self.force
      self.force = true
      block.call
      self.force = old_force
    end
    
    def create_dir(dir_name, options={})
      options = {:echo_exists=>true}.merge(options)
      if File.exists?(dir_name)
        if options[:echo_exists]
          io.log('exist', dir_name)
        end
      else
        FileUtils.mkdir_p(dir_name)
        io.log('create', dir_name)
      end
    end
    
    def create_file(filename, content="")
      do_create_file = Proc.new do
        File.open(filename, "w") { |f| f.write content }
      end
      
      do_overwrite = Proc.new do
        do_create_file.call
        io.log('overwrite', filename)
      end
      
      create_dir(File.dirname(filename), :echo_exists=>false)
      if File.exists?(filename)
        if force
          do_overwrite.call
        else
          answer = io.ask_yes_no_all("overwrite #{filename}?")
          case answer
          when :yes
            do_overwrite.call
          when :no
            io.log('exist', filename)
          when :all
            force = true
            do_overwrite.call
          end
        end
      else
        do_create_file.call
        io.log('create', filename)
      end
    end
    
    def remove_dir(dirname)      
      if !File.exist?(dirname)
        io.log("not exist", dirname)
      elsif !File.directory?(dirname)
        io.log("not dir", dirname)
      else
        begin
          Dir.glob(dirname + "/*") { throw "not empty" }
          is_empty = true
        rescue
          is_empty = false
        end
        
        if !is_empty
          io.log('not empty', dirname)
        elsif
          FileUtils.remove_dir(dirname)
          io.log("remove", dirname)
        end
      end
    end
    
    def remove_file(filename)
      if !File.exists?(filename)
        io.log("not exist", filename)
      elsif !File.file?(filename)
        io.log("not file", filename)
      else
        FileUtils.remove_file(filename)
        io.log("remove", filename)
      end
    end
  end
end