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

  def test_build_info
    assert @client.build_info('test_job')
  end

  def test_build_queue_info
    response = @client.build_queue_info
    assert_kind_of(String, response)
    assert(!response.empty?)
  end

  def test_build!
    response = @client.build!('test_job')
    assert response
  end

  def test_build_with_parameters!
    response = @client.build_with_parameters!('test_job', {})
    assert response
  end

  def test_config_info
    response = @client.config_info('test_job')
    assert response
  end

  def test_create_item!
    response = @client.create_item!({:name=>"new_test_job", :mode=>"hudson.model.FreeStyleProject", :config=>config})
    assert response
  end

  def test_delete!
    response = @client.delete!('new_test_job')
  end

end