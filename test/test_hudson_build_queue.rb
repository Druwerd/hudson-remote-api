require 'test/unit'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'hudson-remote-api.rb'

class TestHudsonBuildQueue < Test::Unit::TestCase
  
  def test_list
    assert Hudson::BuildQueue.list
  end
  
end