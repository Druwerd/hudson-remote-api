require 'test/unit'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'hudson-remote-api.rb'

class TestHudsonJob < Test::Unit::TestCase
  
  def test_list
    assert Hudson::Job.list
  end
  
  def test_list_active
      assert Hudson::Job.list_active
  end
  
  def test_init
    # TODO: load job fixtures
    #assert Hudson::Job.new('test_job')
  end
end