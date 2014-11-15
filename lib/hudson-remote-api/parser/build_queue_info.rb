module Hudson
  module Parser
    class BuildQueueInfo
      attr_accessor :xml, :xml_doc

      def initialize(raw_xml)
        @xml = raw_xml
        @xml_doc = REXML::Document.new(raw_xml)
      end

      def items
        return [] if self.xml_doc.elements["/queue/item"].nil? # there's nothing in the queue

        self.xml_doc.each_element("/queue/item/task").collect{ |job| job.elements["name"].text }
      end

    end
  end
end