require 'test_helper.rb'

class TestHudsonBuild < Test::Unit::TestCase

  def setup
    VCR.use_cassette("#{self.class}_#{__method__}", :record => :new_episodes) do
      assert Hudson::Job.new('test_job').build
      assert Hudson::Build.new('test_job')
    end
  end

  def test_build_info
    VCR.use_cassette("#{self.class}_#{__method__}", :record => :new_episodes) do
      build = Hudson::Build.new('test_job')
      assert_equal 'test_job', build.job.name
  
      assert build.number.to_i > 0, "build number test failed"
  
      assert build.revisions, "build revisions test failed"
      assert build.revisions.kind_of?(Hash), "build revisions is not an Hash"
  
      assert_equal "SUCCESS", build.result, "build result test failed"
  
      assert_nil build.culprit, "build culprit test failed"
    end
  end
  
end