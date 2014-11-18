module Hudson
  module Parser
    
    class JobConfigInfo
      attr_accessor :xml, :xml_doc

      def initialize(raw_xml)
        @xml = raw_xml
        @xml_doc = REXML::Document.new(raw_xml)
      end

      def description
        description_elem = self.xml_doc.elements["/project/description"]
        description_elem ? description_elem.text : ""
      end

      def disabled?

      end

      def block_build_when_downstream_building?

      end

      def block_build_when_upstream_building?

      end

      def concurrent_build?

      end

      def git_repo?
        self.xml_doc.elements["/project/scm"].attributes['class'] == "hudson.plugins.git.GitSCM"
      end

      def git_url
        git_url_elem = self.xml_doc.elements["/project/scm/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url"]
        git_url_elem ? git_url_elem.text : nil
      end

      def git_branch
        git_branch_elem = self.xml_doc.elements['/project/scm/branches/hudson.plugins.git.BranchSpec/name']
        git_branch_elem ? git_branch_elem.text : nil
      end

      def parameterized?
        !self.xml_doc.elements["/project/properties/hudson.model.ParametersDefinitionProperty"].nil?
      end

      def triggers
        Hash.new.tap do |h|
          if triggers_elem = self.xml_doc.elements["/project/triggers"] || self.xml_doc.elements["/project/triggers[@class='vector']"]
            triggers_elem.elements.to_a.each do |trigger|
              spec_text = trigger.elements['spec'].text
              h[trigger.name.to_s] = spec_text.to_s
            end
          end
        end
      end

      def scm_browser_url
        scm_browser_url_elem = self.xml_doc.elements['/project/scm/browser/url']
        scm_browser_url_elem ? scm_browser_url_elem.text : ""
      end

      def scm_broswer_location
        if !self.xml_doc.elements["/project/scm/browser/location"].nil?
          self.xml_doc.elements["/project/scm/browser/location"].text
        end
      end

      def svn_repo?
        !self.xml_doc.elements["/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation/remote"].nil?
      end

      def svn_repository_urls
        if !self.xml_doc.elements["/project/scm/locations"].nil?
          Array.new.tap do |a|
            self.xml_doc.elements.each("/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation"){|e| a << e.elements["remote"].text }
          end
        end
      end

      def git_repository
        Hash.new.tap do |h|
          h[:url] = self.git_url
          h[:branch] = self.git_branch
        end
      end

      def svn_repository
        repo_elem = self.xml_doc.elements["/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation/remote"]
        repo_elem ? repo_elem.text : ""
      end
    end

  end
end