module Hudson
  module Parser
    class JobInfo
      attr_accessor :xml, :xml_doc

      def initialize(raw_xml)
        @xml = raw_xml
        @xml_doc = REXML::Document.new(raw_xml)
      end

      def builds
        Array.new().tap do |a|
          self.xml_doc.elements.each("/freeStyleProject/build"){|e| a << e.elements["number"].text } unless self.xml_doc.elements["/freeStyleProject/build"].nil?
        end
      end

      def color
        color_elem = self.xml_doc.elements["/freeStyleProject/color"]
        color_elem.text if free_style_project? && color_elem
      end

      def free_style_project?
        !self.xml_doc.elements["/freeStyleProject"].nil?
      end

      def last_build
        read_elem_text("/freeStyleProject/lastBuild/number") if free_style_project?
      end

      def last_completed_build
        read_elem_text("/freeStyleProject/lastCompletedBuild/number") if free_style_project?
      end

      def last_failed_build
        read_elem_text("/freeStyleProject/lastFailedBuild/number") if free_style_project?
      end

      def last_stable_build
        read_elem_text("/freeStyleProject/lastStableBuild/number") if free_style_project?
      end

      def last_successful_build
        read_elem_text("/freeStyleProject/lastSuccessfulBuild/number") if free_style_project?
      end

      def last_unsuccessful_build
        read_elem_text("/freeStyleProject/lastUnsuccessfulBuild/number") if free_style_project?
      end

      def next_build_number
        read_elem_text("/freeStyleProject/nextBuildNumber") if free_style_project?
      end

      private
      def read_elem_text(elem_path)
        elem = self.xml_doc.elements[elem_path]
        elem.text if elem
      end

    end
  end
end