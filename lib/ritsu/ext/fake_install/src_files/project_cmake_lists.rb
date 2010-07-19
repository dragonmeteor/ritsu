require File.dirname(__FILE__) + "/../../../src_files/project_cmake_lists"

module Ritsu
  module SrcFiles
    class ProjectCmakeLists
      class FakeInstallTemplate < Ritsu::Template
        attr_reader :project
        
        def initialize(project)
          super("ProjectCmakeLists -- Fake Install")
          @project = project          
        end
        
        def update_block(block, options={})
          block.contents.clear
          
          to_install = project.targets.select { |x| x.install? }
          
          if project.performs_fake_install? && to_install.length > 0
            block.add_line "ADD_CUSTOM_TARGET(fake_install"
            block.add_line "    ALL"
            block.add_line "    \"${CMAKE_COMMAND}\""
            block.add_line "    -D CMAKE_INSTALL_PREFIX:string=${CMAKE_SOURCE_DIR}/../"
            block.add_line "    -P \"${CMAKE_CURRENT_BINARY_DIR}/cmake_install.cmake\""
            block.add_line "    DEPENDS"
            to_install.each do |target|
              block.add_line "        #{target.name}"
            end
            block.add_line ")"
          end
        end
      end      
      
      class Template
        alias_method :initialize_before_fake_install, :initialize
        
        def initialize(project)
          initialize_before_fake_install(project)
          add_new_line
          add_template FakeInstallTemplate.new(project)
        end
      end
    end
  end
end