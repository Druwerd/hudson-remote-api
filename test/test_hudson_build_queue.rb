require 'test_helper.rb'

class TestHudsonBuildQueue < Test::Unit::TestCase
  
  def test_list
    VCR.use_cassette("#{self.class}_#{__method__}") do
      assert Hudson::BuildQueue.list
    end
  end

end
