require 'test_helper.rb'

class TestHudsonJob < Test::Unit::TestCase
  TEST_SVN_REPO_URL = "http://svn.apache.org/repos/asf/subversion/trunk/doc/user/"
  
  def setup
    Hudson.client.configuration.host = "http://localhost:8080"
  end
  
  def test_list
    VCR.use_cassette("#{self.class}_#{__method__}") do
      assert Hudson::Job.list
    end
  end
  
  def test_list_active
    VCR.use_cassette("#{self.class}_#{__method__}") do
      assert Hudson::Job.list_active
    end
  end
  
  def test_create
    VCR.use_cassette("#{self.class}_#{__method__}") do
      new_job_name = 'new_test_job'
      new_job = Hudson::Job.create(new_job_name)
      assert new_job
      assert_equal(new_job_name, new_job.name)
      assert_equal(true, new_job.triggers.empty?, "New job should have empty triggers")
      assert new_job.delete
    end
  end
  
  def test_get
    VCR.use_cassette("#{self.class}_#{__method__}") do
      job = Hudson::Job.get('test_job')
      assert job
      assert_equal 'test_job', job.name, "failed to get job name"
    end
  end
  
  def test_desc_update
    VCR.use_cassette("#{self.class}_#{__method__}", :record => :new_episodes) do
      job = Hudson::Job.new('test_job')
      assert job.description = "test"
      assert job.description != nil, "Job description should not be nil"
    end
  end
  
  def test_scm_url
    VCR.use_cassette("#{self.class}_#{__method__}", :record => :new_episodes) do
      job = Hudson::Job.new('test_svn_job')
      job.build
      assert job.repository_url = TEST_SVN_REPO_URL
    
      job = Hudson::Job.new('test_svn_job')
      assert_equal TEST_SVN_REPO_URL, job.repository_url
    end
  end
  
  def test_new
    VCR.use_cassette("#{self.class}_#{__method__}") do
      job = Hudson::Job.new('test_job')
      assert job
      assert_equal('test_job', job.name)
    
      new_job = Hudson::Job.new('test_job2')
      assert new_job
      assert_equal(new_job.name, 'test_job2')
      assert new_job.delete
    end
  end
  
  def test_copy
    VCR.use_cassette("#{self.class}_#{__method__}") do
      job = Hudson::Job.get('test_job')
      new_job = job.copy
      assert new_job
      assert_equal('copy_of_test_job', new_job.name)
      assert new_job.delete
    end
  end
  
  def test_job_with_spaces
    VCR.use_cassette("#{self.class}_#{__method__}") do
      job = Hudson::Job.create('test job with spaces')
      assert job
      assert job.name
      assert job.delete
    end
  end
  
  def test_builds_list
    VCR.use_cassette("#{self.class}_#{__method__}") do
      job = Hudson::Job.get("test_job")
      assert job.builds_list.kind_of?(Array)
    end
  end

  def test_build
    VCR.use_cassette("#{self.class}_#{__method__}") do
      job_name = 'test_job'
      job = Hudson::Job.new(job_name)

      assert job.build
    end
  end

  def test_build_with_params
    VCR.use_cassette("#{self.class}_#{__method__}") do
      job_name = 'test_job'
      job = Hudson::Job.new(job_name)

      assert job.build
    end
  end

  def test_triggers_set
    VCR.use_cassette("#{self.class}_#{__method__}") do
      job_name = 'build_triggers'
      job = Hudson::Job.create(job_name)

      job.triggers = { "hudson.triggers.SCMTrigger" => '* * * * *' }
      assert_equal(1, job.triggers.size, "Failed to set triggers with 1 trigger.")
      assert_equal({"hudson.triggers.SCMTrigger" => '* * * * *'}, job.triggers, "Failed to set triggers with 1 trigger.")

      assert job.delete
    end
  end

  def test_triggers_set_using_shortcut
    VCR.use_cassette("#{self.class}_#{__method__}") do
      job_name = 'build_triggers'
      job = Hudson::Job.create(job_name)

      job.triggers = { "SCMTrigger" => '* * * * *', 'TimerTrigger' => '0 22 * * *' }
      assert_equal(2, job.triggers.size, "Failed to set triggers using shortcut.")
      assert_equal({"hudson.triggers.SCMTrigger"=>"* * * * *", "hudson.triggers.TimerTrigger"=>"0 22 * * *"}, job.triggers, "Failed to set triggers using shortcut.")

      assert job.delete
    end
  end

  def test_triggers_delete
    VCR.use_cassette("#{self.class}_#{__method__}", :record => :new_episodes) do
      job_name = 'build_triggers'
      job = Hudson::Job.create(job_name)

      job.triggers = { "SCMTrigger" => '* * * * *', 'TimerTrigger' => '0 22 * * *' }
      job.triggers = {}
      assert_equal(true, job.triggers.empty?, "Failed to delete triggers.")

      assert job.delete
    end
  end
end
