require 'test/unit'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'hudson-remote-api.rb'

class TestHudsonMulticast < Test::Unit::TestCase
  
  def test_multicast
    assert_nothing_thrown{ Hudson.discover }
  end
  
end