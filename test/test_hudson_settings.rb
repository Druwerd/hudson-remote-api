require 'test_helper.rb'

class TestHudsonBuild < Test::Unit::TestCase

  def setup
    
  end

  def test_initialization
    settings_hash = {
      :host => 'http://localhost:8080', 
      :user => 'test_user', 
      :password => 'test_password', 
      :version => 'test_version', 
      :crumb => 'test_crumb',
      :proxy_host => 'test_proxy_host',
      :proxy_port => 'test_proxy_port'
    }
    settings = Hudson::Settings.new(settings_hash)
    assert_equal 'http://localhost:8080', settings.configuration.host
    assert_equal 'test_user', settings.configuration.user
    assert_equal 'test_password', settings.configuration.password
    assert_equal 'test_version', settings.configuration.version
    assert_equal 'test_crumb', settings.configuration.crumb
    assert_equal 'test_proxy_host', settings.configuration.proxy_host
    assert_equal 'test_proxy_port', settings.configuration.proxy_port
  end

  def test_host_assignment
    settings = Hudson::Settings.new({})
    settings.configuration.host = "http://test.com"
    assert_equal "http://test.com", settings.configuration.host
  end

  def test_user_assignment
    settings = Hudson::Settings.new({})
    settings.configuration.user = "test_user"
    assert_equal "test_user", settings.configuration.user
  end

  def test_password_assignment
    settings = Hudson::Settings.new({})
    settings.configuration.password = "test_password"
    assert_equal "test_password", settings.configuration.password
  end

  def test_version_assignment
    settings = Hudson::Settings.new({})
    settings.configuration.version = "test_version"
    assert_equal "test_version", settings.configuration.version
  end

  def test_crumb_assignment
    settings = Hudson::Settings.new({})
    settings.configuration.crumb = "test_crumb"
    assert_equal "test_crumb", settings.configuration.crumb
  end

  def test_proxy_host_assignment
    settings = Hudson::Settings.new({})
    settings.configuration.proxy_host = "http://test.com"
    assert_equal "http://test.com", settings.configuration.proxy_host
  end

  def test_url_assignment
    settings = Hudson::Settings.new({})
    settings.configuration.proxy_port = "12345"
    assert_equal "12345", settings.configuration.proxy_port
  end
end