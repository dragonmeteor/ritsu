require 'rubygems'
require 'active_support/core_ext/string/inflections'
require File.dirname(__FILE__) + "/templated_src_file"
require File.dirname(__FILE__) + "/../template_policies"
require File.dirname(__FILE__) + "/../template"
require File.dirname(__FILE__) + "/../utility/platform"
require File.dirname(__FILE__) + "/header_file_mixin"

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
      
      def include_in_cmake?
        false
      end
    end
  end
end