require 'rubygems'
require 'thor'
require File.expand_path(File.dirname(__FILE__) + '/../project')
require File.expand_path(File.dirname(__FILE__) + '/../utility/platform')

module Ritsu::Thors
  class DefaultThor < Thor
    desc "update_src", "update all the source files"
    def update_src
      Ritsu::Project.instance.update
    end

    desc "cmake", "run CMake"
    method_option :generator, :type => :string
    def cmake
      prepare_cmake_generator
      
      if !File.exists?(Ritsu::Project.instance.project_dir + "/build")
        FileUtils.mkdir_p(Ritsu::Project.instance.project_dir + "/build")
      end

      FileUtils.chdir("build", :verbose => true)
      system("cmake ../src -G\"#{@cmake_generator}\"")
    end

    desc "update", "update source files and then run CMake"
    method_option :generator, :type => :string
    def update
      prepare_cmake_generator
            
      update_src
      cmake
    end
    
    protected
      def prepare_cmake_generator
        if !options.has_key?(:generator)
          @cmake_generator = default_cmake_generator(Ritsu::Utility.platform)
        else
          @cmake_generator = options[:generator]
        end
      end
      
      def default_cmake_generator(platform)
        platform = platform.to_sym
        case platform
        when :windows
          "Visual Studio 9 2008"
        when :mac
          "Xcode"
        when :unix
          "Unix Makefiles"
        else
          raise ArgumentError.new("invalid platform '#{platform.to_s}'")
        end
      end
  end
end