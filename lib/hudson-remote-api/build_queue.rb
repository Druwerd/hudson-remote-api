module Hudson
  # This class provides an interface to Hudson's build queue
  class BuildQueue < HudsonObject

    def self.load_xml_api
      @@xml_api_build_queue_info_path = File.join(Hudson[:url], "queue/api/xml")
    end

    load_xml_api

    # List the jobs in the queue
    def self.list()
      xml = get_xml(@@xml_api_build_queue_info_path)
      queue = []
      queue_doc = REXML::Document.new(xml)
      return queue if queue_doc.elements["/queue/item"].nil?
      queue_doc.each_element("/queue/item/task") do |job|
        queue << job.elements["name"].text
      end
      queue
    end
  end
end
