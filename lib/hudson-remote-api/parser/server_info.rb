module Hudson
  module Parser
    class ServerInfo
      attr_accessor :xml, :xml_doc

      def initialize(raw_xml)
        @xml = raw_xml
        @xml_doc = REXML::Document.new(raw_xml)
      end

      def active_jobs
        Array.new().tap do |active_jobs|
          self.xml_doc.each_element("hudson/job") do |job|
            active_jobs << job.elements["name"].text if job.elements["color"].text.include?("anime")
          end
        end
      end

      def mode
        self.xml_doc.elements["/hudson/mode"].text
      end

      def node_description
        self.xml_doc.elements["/hudson/nodeDescription"].text
      end

      def node_name
        self.xml_doc.elements["/hudson/nodeName"].text
      end

      def jobs
        Array.new.tap do |j|
          self.xml_doc.each_element("hudson/job") do |job|
            j << job.elements["name"].text
          end
        end
      end

      def use_crumbs?
        self.xml_doc.elements["/hudson/useCrumbs"].text == "true"
      end

      def use_security?
        self.xml_doc.elements["/hudson/useSecurity"].text == "true"
      end

    end
  end
end