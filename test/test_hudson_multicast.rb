require 'test_helper.rb'

class TestHudsonMulticast < Test::Unit::TestCase
  
  def test_multicast
    assert_nothing_thrown{ Hudson.discover }
  end
  
end