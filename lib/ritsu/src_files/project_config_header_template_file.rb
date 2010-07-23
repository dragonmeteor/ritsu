require 'rubygems'
require 'active_support/core_ext/string/inflections'
require File.expand_path(File.dirname(__FILE__) + "/templated_src_file")
require File.expand_path(File.dirname(__FILE__) + "/../template_policies")
require File.expand_path(File.dirname(__FILE__) + "/../template")
require File.expand_path(File.dirname(__FILE__) + "/../utility/platform")

module Ritsu
  module SrcFiles
    class ProjectConfigHeaderTemplateFile < Ritsu::SrcFiles::TemplatedSrcFile
      class Template < Ritsu::Template
        include Ritsu::TemplatePolicies::DoNotUpdate
        
        attr_reader :src_file
        
        def initialize(src_file)
          @src_file = src_file
          super("ProjectConfigHeaderTemplateFile -- #{project.name}")
          
          add_line "#ifndef __#{project.name.underscore.upcase}_CONFIG_H__"
          add_line "#define __#{project.name.underscore.upcase}_CONFIG_H__"
          add_new_line
          add_line "#cmakedefine __WIN_PLATFORM__"
          add_line "#cmakedefine __MAC_PLATFORM__"
          add_line "#cmakedefine __UNIX_PLATFORM__"
          add_new_line
          add_line "#endif"
        end
        
        def project
          src_file.project
        end
      end
      
      def initialize(project)
        super("config.h.in", project)
        self.template = Template.new(self)
      end
      
      def include_in_source_files?
        false
      end
    end
  end
end