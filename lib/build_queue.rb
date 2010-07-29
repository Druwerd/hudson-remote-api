require File.dirname(__FILE__) + '/base.rb'
module Hudson
    # This class provides an interface to Hudson's build queue
    class BuildQueue < HudsonObject
        # List the jobs in the queue
        def self.list()
            path = "#{HUDSON_URL_ROOT}/queue/api/xml"
            uri = URI::HTTP.build(:host => @@host, :path => path, :port => @@port)
            response = Net::HTTP.get_response(uri)
            
            if response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
                queue = []
                queue_doc = REXML::Document.new(response.body)
                return queue if queue_doc.elements["/queue/item"].nil?
                queue_doc.each_element("/queue/item/task") do |job|
                    queue << job.elements["name"].text
                end
                queue
            else
                raise HudsonApiError, "Error retrieving build queue"
            end
        end
    end
end