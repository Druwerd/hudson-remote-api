require 'hudson-remote-api'
module Hudson
    # This class provides an interface to Hudson's build queue
    class BuildQueue < HudsonObject
        # List the jobs in the queue
        def self.list()
            path = "#{Hudson[:url_root]}/queue/api/xml"
            xml = get_xml(path)
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