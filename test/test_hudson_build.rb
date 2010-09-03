require 'test/unit'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'hudson-remote-api.rb'

class TestHudsonBuild < Test::Unit::TestCase
  
  def test_init
    # TODO: load hudson build fixtures
    #assert Hudson::Build.new('test_job')
  end
  
end