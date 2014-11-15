require 'test_helper.rb'

class TestHudsonBuild < Test::Unit::TestCase

  def setup
    
  end

  def test_initialization
    settings_hash = {
      :url => 'http://localhost:8080', 
      :user => 'test_user', 
      :password => 'test_password', 
      :version => 'test_version', 
      :crumb => 'test_crumb',
      :proxy_host => 'test_proxy_host',
      :proxy_port => 'test_proxy_port'
    }
    settings = Hudson::Settings.new(settings_hash)
    assert_equal 'http://localhost:8080', settings.config.url
    assert_equal 'test_user', settings.config.user
    assert_equal 'test_password', settings.config.password
    assert_equal 'test_version', settings.config.version
    assert_equal 'test_crumb', settings.config.crumb
    assert_equal 'test_proxy_host', settings.config.proxy_host
    assert_equal 'test_proxy_port', settings.config.proxy_port
  end

  def test_url_assignment
    settings = Hudson::Settings.new({})
    settings.config.url = "http://test.com"
    assert_equal "http://test.com", settings.config.url
  end

  def test_user_assignment
    settings = Hudson::Settings.new({})
    settings.config.user = "test_user"
    assert_equal "test_user", settings.config.user
  end

  def test_password_assignment
    settings = Hudson::Settings.new({})
    settings.config.password = "test_password"
    assert_equal "test_password", settings.config.password
  end

  def test_version_assignment
    settings = Hudson::Settings.new({})
    settings.config.version = "test_version"
    assert_equal "test_version", settings.config.version
  end

  def test_crumb_assignment
    settings = Hudson::Settings.new({})
    settings.config.crumb = "test_crumb"
    assert_equal "test_crumb", settings.config.crumb
  end

  def test_proxy_host_assignment
    settings = Hudson::Settings.new({})
    settings.config.proxy_host = "http://test.com"
    assert_equal "http://test.com", settings.config.proxy_host
  end

  def test_url_assignment
    settings = Hudson::Settings.new({})
    settings.config.proxy_port = "12345"
    assert_equal "12345", settings.config.proxy_port
  end
end