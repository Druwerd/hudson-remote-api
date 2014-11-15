module Hudson
  # This class provides an interface to Hudson's build queue
  class BuildQueue
    
    class << self
      def list
        xml = Hudson.client.build_queue_info
        build_queue_info_parser = Hudson::Parser::BuildQueueInfo.new(xml)

        build_queue_info_parser.items
      end
    end

  end

end
