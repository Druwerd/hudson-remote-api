require 'test/unit'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'hudson-remote-api.rb'

class TestHudsonJob < Test::Unit::TestCase
  
  def setup
    Hudson[:url] = "http://localhost:8080"
  end
  
  def test_list
    assert Hudson::Job.list
  end
  
  def test_list_active
      assert Hudson::Job.list_active
  end
  
  def test_init
    # TODO: load job fixtures
    job = Hudson::Job.new('test_job')
    assert job
    assert job.last_build, "failed to get last build number"
  end
end