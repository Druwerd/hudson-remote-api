require 'test_helper.rb'

class TestHudsonConfig < Test::Unit::TestCase
  
  def test_get
    assert Hudson[:url]
  end
  
  def test_set
    test_url = "test.host.com"
    Hudson[:url] = test_url
    assert_equal("http://#{test_url}", Hudson[:url])
  end
  
  def test_load_settings_hash
    new_settings = {:url => 'test.com', :user => 'test', :password => 'test', :version => '1.00'}
    Hudson.settings = new_settings
    assert_equal("http://#{new_settings[:url]}", Hudson[:url])
    assert_equal("test", Hudson[:user])
    assert_equal("test", Hudson[:password])
    assert_equal("1.00", Hudson[:version])
    assert_equal(true, Hudson[:crumb])
  end
  
  def test_auto_config
    assert_nothing_thrown{ Hudson.auto_config }
  end

  def test_when_crumb_is_false
    new_settings = {:url => 'test.com', :user => 'test', :password => 'test', :version => '1.00', :crumb => false}
    Hudson.settings = new_settings
    assert_equal(false, Hudson[:crumb])
  end

  def test_proxy_setting
    new_settings = {:url => 'test.com', :user => 'test', :password => 'test', :version => '1.00', :proxy_host => 'test-proxy.com', :proxy_port => 9876}
    Hudson.settings = new_settings
    assert_equal('test-proxy.com', Hudson[:proxy_host])
    assert_equal(9876, Hudson[:proxy_port])
  end
  
end
