require File.expand_path(File.dirname(__FILE__) + '/../../target')

module Ritsu
  class Target
    alias_method :initialize_target_before_cuda, :initialize
    
    def initialize(name, options={})
      options = {:cuda_target => false}.merge(options)
      initialize_target_before_cuda(name, options)
      @cuda_target = options[:cuda_target]
    end
    
    def cuda_target?
      @cuda_target
    end
  end
end