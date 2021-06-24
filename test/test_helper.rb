$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "better"
require 'amazing_print'

require "minitest/autorun"

class MiniTest::Test
  extend MiniTest::Spec::DSL
end
