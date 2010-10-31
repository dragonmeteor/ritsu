require File.expand_path(File.dirname(__FILE__) + '/../../external_library.rb')

module Ritsu
  class ExternalLibrary    
    attr_accessor :cuda_depend_script
    attr_method :cuda_depend_script
    
    alias_method :initialize_before_cuda, :initialize
    
    def initialize(name, options={})
      options = {:cuda_depend_script => ''}.merge(options)
      initialize_before_cuda(name, options)
      @cuda_depend_script = options[:cuda_depend_script]
    end
  end
end