require 'ostruct'

module Better
  class Context < OpenStruct
    attr_reader :success

    def initialize(hash = nil)
      @success = true
      super(hash)
    end

    def success?
      @success
    end

    def failure?
      !@success
    end
  end
end
