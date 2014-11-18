module Hudson
  module XmlWriter

    class JobConfigInfo
      attr_accessor :job_name, :xml_doc

SVN_SCM_CONF = <<-SVN_SCM_STRING
  <scm class="hudson.scm.SubversionSCM">
  <locations>
  <hudson.scm.SubversionSCM_-ModuleLocation>
  <remote>%s</remote>
  <local>.</local>
  </hudson.scm.SubversionSCM_-ModuleLocation>
  </locations>
  <excludedRegions/>
  <includedRegions/>
  <excludedUsers/>
  <excludedRevprop/>
  <excludedCommitMessages/>
  <workspaceUpdater class="hudson.scm.subversion.UpdateUpdater"/>
  </scm>
    SVN_SCM_STRING

      def initialize(job_name, raw_xml)
        @job_name = job_name
        @xml_doc = REXML::Document.new(raw_xml)
      end

      def git_repository_url=(repository_url)
        if repository_url[:url]
          self.xml_doc.elements['/project/scm/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url'].text = repository_url[:url]
        end
        if repository_url[:branch]
          self.xml_doc.elements['/project/scm/branches/hudson.plugins.git.BranchSpec/name'].text = repository_url[:branch]
        end
        update
      end

      def svn_repository_url=(repository_url)
        if self.xml_doc.elements["/project/scm"].attributes['class'] == "hudson.scm.NullSCM"
          self.xml_doc.elements["/project/scm"].replace_with REXML::Document.new(SVN_SCM_CONF % repository_url)
        else
          self.xml_doc.elements["/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation/remote"].text = repository_url
        end
        update
      end

      def repository_urls=(repository_urls)
        return false if !repository_urls.class == Array

        i = 0
        self.xml_doc.elements.each("/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation") do |location|
          location.elements["remote"].text = repository_urls[i]
          i += 1
        end
        update
      end

      def git_repository_browser_location=(repository_browser_location)
        self.xml_doc.elements['/project/scm/browser/url'].text = repository_browser_location
        update
      end

      def svn_repository_browser_location=(repository_browser_location)
        self.xml_doc.elements["/project/scm/browser/location"].text = repository_browser_location
        update
      end

      def description=(description)
        self.xml_doc.elements["/project"] << REXML::Element.new("description") if self.xml_doc.elements["/project/description"].nil?
        self.xml_doc.elements["/project/description"].text = description
        update
      end

      def triggers= opts={}
        opts = {} if opts.nil?
        if triggers = self.xml_doc.elements["/project/triggers"] || self.xml_doc.elements["/project/triggers[@class='vector']"]
          triggers.elements.delete_all '*'
          opts.each do |key, value|
            trigger_name = key.to_s
            trigger_name = 'hudson.triggers.' + trigger_name unless Regexp.new(/^hudson\.triggers\./).match(trigger_name)
            if trigger = triggers.elements[trigger_name]
              if spec = trigger.elements['spec']
                spec.text = value.to_s
              else
                triggers.elements << generate_trigger(trigger, value)
              end
            else
              triggers.elements << generate_trigger(REXML::Element.new(trigger_name), value)
            end
          end
          update
        else
          $stderr.puts "triggers not found in configuration, triggers assignment ignored."
        end
      end

      private
        def update
          response = Hudson.client.update_job_config!(self.job_name, self.xml_doc.to_s)
          response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end

        def generate_trigger trigger, spec_text
          spec = REXML::Element.new("spec")
          spec.text = spec_text.to_s
          trigger.elements << spec
          trigger
        end
    end

  end
end