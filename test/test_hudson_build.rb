require 'test/unit'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'hudson-remote-api.rb'

class TestHudsonBuild < Test::Unit::TestCase
  
  def test_init
    assert Hudson::Job.new('test_job').build
    assert Hudson::Build.new('test_job')
  end
  
  def test_build_info
    build = Hudson::Build.new('test_job')
    assert_equal build.job.name, 'test_job'
    
    assert build.number.to_i > 0
    
    assert build.revisions
    
    assert_equal build.result, "SUCCESS"
    
    assert_nil build.culprit
  end
  
end