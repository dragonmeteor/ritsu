require File.expand_path(File.dirname(__FILE__) + "/../../project")

module Ritsu
  class Project
    def performs_fake_install?
      @fake_install ||= false
    end
    
    def fake_install=(value)
      @fake_install = value
    end
    
    def setup_fake_install
      @fake_install = true
    end
  end
end