module Ritsu
  module Utility
    def platform
      case RUBY_PLATFORM.downcase
      when /linux|bsd|solaris|hpux/
        :unix
      when /darwin/
        :mac
      when /mswin32|mingw32|bccwin32/
        :windows
      when /cygwin/
        :cygwin
      when /java/
        :java
      else
        :other
      end
    end
    module_function :platform
  end
end