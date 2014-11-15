require 'test_helper.rb'

class TestHudsonClient < Test::Unit::TestCase

  def setup
    @client = Hudson.client
  end

  def config
    File.open(File.dirname(__FILE__) + '/../lib/hudson-remote-api/new_job_config.xml').read
  end

  def test_initialization
    Hudson::Client.new
  end

  def test_job_build_info
    assert @client.job_build_info('test_job', 1)
  end

  def test_build_queue_info
    response = @client.build_queue_info
    assert_kind_of(String, response)
    assert(!response.empty?)
  end

  def test_build_job!
    response = @client.build_job!('test_job')
    assert response
  end

  def test_build_job_with_parameters!
    response = @client.build_job_with_parameters!('test_job', {})
    assert response
  end

  def test_job_config_info
    response = @client.job_config_info('test_job')
    assert response
  end

  def test_create_item!
    response = @client.create_item!({:name=>"new_test_job", :mode=>"hudson.model.FreeStyleProject", :config=>config})
    assert response
  end

  def test_delete_job!
    response = @client.delete_job!('new_test_job')
  end

end