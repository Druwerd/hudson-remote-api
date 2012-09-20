require 'test_helper.rb'

class TestHudsonBuildQueue < Test::Unit::TestCase
  
  def test_list
    VCR.use_cassette("#{self.class}_#{__method__}") do
      assert Hudson::BuildQueue.list
    end
  end
  
  def test_load_xml_api
    VCR.use_cassette("#{self.class}_#{__method__}") do
      Hudson[:url] = "test.host.com"
      assert_equal("http://test.host.com/queue/api/xml",
                   Hudson::BuildQueue.__send__("class_variable_get", "@@xml_api_build_queue_info_path"))
    end
  end
end
