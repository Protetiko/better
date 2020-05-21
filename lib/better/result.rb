# The validator can be any class/proc/lamba that implements the call method
# and returns a Result object.
#

module Better
  class Result
    attr_reader :success, :errors
    alias_method :success?, :success

    def self.fail(*errors)
      return self.new(false, *errors)
    end

    def self.success
      return self.new
    end

    def initialize(success = true, *errors)
      @success = success
      @errors = errors || []
    end

    def failure?
      !success
    end

    def fail(*errors)
      @success = false
      @errors += errors
    end

    def <<(result)
      @success &= result.success
      @errors += result.errors unless result.success
    end
  end
end
