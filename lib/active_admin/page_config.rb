module ActiveAdmin
  class PageConfig

    attr_accessor :block

    def initialize(options = {}, &block)
      @options, @block = options, block
    end

    def [](key)
      @options[key]
    end
      
  end
end
