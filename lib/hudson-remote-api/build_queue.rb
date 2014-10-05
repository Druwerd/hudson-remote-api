module Hudson
  # This class provides an interface to Hudson's build queue
  class BuildQueue < HudsonObject
    
    class << self
      def load_xml_api
        @@xml_api_build_queue_info_path = File.join(Hudson[:url], "queue/api/xml")
      end

      def list
        xml = get_xml(@@xml_api_build_queue_info_path)
        queue_doc = REXML::Document.new(xml)
        return [] if queue_doc.elements["/queue/item"].nil? # there's nothing in the queue

        queue_doc.each_element("/queue/item/task").collect{ |job| job.elements["name"].text }
      end
    end

    load_xml_api
  end

end
