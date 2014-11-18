module Hudson
  module Parser

    class BuildInfo
      attr_accessor :xml, :xml_doc

      def initialize(raw_xml)
        @xml = raw_xml
        @xml_doc = REXML::Document.new(raw_xml)
      end

      def result
        build_result_element = self.xml_doc.elements["/freeStyleBuild/result"]

        build_result_element.respond_to?(:text) ? build_result_element.text : nil
      end

      def revisions
        return nil unless self.xml_doc.elements["/freeStyleBuild/changeSet"]

        Hash.new().tap do |h|
          self.xml_doc.elements.each("/freeStyleBuild/changeSet/revision") do |revision|
            h[revision.elements["module"].text] = revision.elements["revision"].text
          end
        end
      end

      def culprit
        culprit_element = self.xml_doc.elements['/freeStyleBuild/culprit/fullName']

        if culprit_element.respond_to?(:text) ? culprit_element.text : nil
        end
      end
    end

  end
end