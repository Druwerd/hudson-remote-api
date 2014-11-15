module Hudson
  module Parser
    class Multicast
      attr_accessor :xml, :xml_doc

      def initialize(raw_xml)
        @xml = raw_xml
        @xml_doc = REXML::Document.new(raw_xml)
      end

      def version
        version_element = self.xml_doc.elements["/hudson/version"]
        version_element.respond_to?(:text) ? version_element.text : nil
      end

      def url
        url_element = self.xml_doc.elements["/hudson/url"]
        url_element.respond_to?(:text) ? url_element.text : nil
      end

      def slave_port
        slave_port_element = self.xml_doc.elements["/hudson/slave-port"]
        slave_port_element.respond_to?(:text) ? slave_port_element.text : nil
      end

    end
  end
end