require 'test/unit'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'hudson-remote-api.rb'

class TestHudsonBuild < Test::Unit::TestCase
  
  def setup
    assert Hudson::Job.new('test_job').build
    assert Hudson::Build.new('test_job')
  end
  
  def test_build_info
    build = Hudson::Build.new('test_job')
    assert_equal build.job.name, 'test_job'
    
    assert build.number.to_i > 0, "build number test failed"
    
    assert build.revisions, "build revisions test failed"
    assert build.revisions.kind_of?(Array), "build revisions is not an Array"
    
    assert_equal build.result, "SUCCESS", "build result test failed"
    
    assert_nil build.culprit, "build culprit test failed"
  end
  
end