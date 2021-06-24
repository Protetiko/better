require "test_helper"

class ContextTest < Minitest::Test
  def test_context
    context = Better::Context.new
    assert context.success?
    assert context.success

    context = Better::Context.new(username: 'jimbob')
    assert_equal 'jimbob', context.username
  end
end

