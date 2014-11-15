module Hudson
  # This class provides an interface to Hudson jobs
  class Job < HudsonObject
    attr_accessor :name, :config, :repository_url, :repository_urls, :repository_browser_location, :description, :parameterized_job

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

    # Class methods
    class <<self
      # List all Hudson jobs
      def list()
        xml = Hudson.client.server_info
        server_info_parser = Hudson::Parser::ServerInfo.new(xml)

        server_info_parser.jobs
      end

      # List all jobs in active execution
      def list_active
        xml = Hudson.client.server_info
        server_info_parser = Hudson::Parser::ServerInfo.new(xml)

        server_info_parser.active_jobs
      end

      def get(job_name)
        job_name.strip!
        list.include?(job_name) ? Job.new(job_name) : nil
      end

      def create(name, config=nil)
        config ||= File.open(File.dirname(__FILE__) + '/new_job_config.xml').read
        response = Hudson.client.create_item!({:name=>name, :mode=>"hudson.model.FreeStyleProject", :config=>config})
        raise(APIError, "Error creating job #{name}: #{response.body}") if response.class != Net::HTTPFound
        Job.get(name)
      end

    end

    # Instance methods
    def initialize(name, config=nil)
      name.strip!
      # Creates the job in Hudson if it doesn't already exist
      @name = Job.list.include?(name) ? name : Job.create(name, config).name
      load_config
      self
    end

    # Load data from Hudson's Job configuration settings into class variables
    def load_config
      @config = Hudson.client.config_info(self.name)
      @config_info_parser = Hudson::Parser::JobConfigInfo.new(@config)

      @info = Hudson.client.job_info(self.name)
      @job_info_parser = Hudson::Parser::JobInfo(@info)

      @description = @config_info_parser.description
      @parameterized_job = @config_info_parser.parameterized?
      @git = @config_info_parser.git_repo?
      @repository_url = @config_info_parser.repository_url
      @repostory_urls = @config_info_parse.repostory_urls
      @repository_browser_location = @config_info_parser.repository_browser_location
    end

    def free_style_project?
      @free_style_project ||= @job_info_parser.free_style_project?
    end

    def color
      @color ||= @job_info_parser.color
    end

    def last_build
      @job_info_parser.last_build
    end

    def last_completed_build
      @job_info_parser.last_completed_build
    end

    def last_failed_build
      @job_info_parser.last_failed_build
    end

    def last_stable_build
      @job_info_parser.last_stable_build
    end

    def last_successful_build
      @job_info_parser.last_successful_build
    end

    def last_unsuccessful_build
      @job_info_parser.last_unsuccessful_build
    end

    def next_build_number
      @job_info_parser.next_build_number
    end

    def builds_list
      @job_info_parser.builds
    end

    def active?
      Job.list_active.include?(self.name)
    end

    def wait_for_build_to_finish(poll_freq=10)
      loop do
        puts "waiting for all #{@name} builds to finish"
        sleep poll_freq # wait
        break if !active? and !BuildQueue.list.include?(@name)
      end
    end

    # Create a new job on Hudson server based on the current job object
    def copy(new_job=nil)
      new_job = "copy_of_#{@name}" if new_job.nil?
      response = Hudson.client.create_item!({:name=>new_job, :mode=>"copy", :from=>@name})
      raise(APIError, "Error copying job #{@name}: #{response.body}") if response.class != Net::HTTPFound
      Job.new(new_job)
    end

    # Update the job configuration on Hudson server
    def update(config=nil)
      @config = config if !config.nil?
      response = Hudson.client.update_job_config!(self.name, @config)
      response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
    end

    # Set the repository url and update on Hudson server
    def repository_url=(repository_url)
      #return false if @repository_url.nil?

      @repository_url = repository_url

      if @git
        if repository_url[:url]
          @config_doc.elements['/project/scm/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url'].text = repository_url[:url]
        end
        if repository_url[:branch]
          @config_doc.elements['/project/scm/branches/hudson.plugins.git.BranchSpec/name'].text = repository_url[:branch]
        end
      else
        if @config_doc.elements["/project/scm"].attributes['class'] == "hudson.scm.NullSCM"
          @config_doc.elements["/project/scm"].replace_with REXML::Document.new(SVN_SCM_CONF % repository_url)
        else
          @config_doc.elements["/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation/remote"].text = repository_url
        end
      end

      @config = @config_doc.to_s
      update
    end

    def repository_urls=(repository_urls)
      return false if !repository_urls.class == Array
      @repository_urls = repository_urls

      i = 0
      @config_doc.elements.each("/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation") do |location|
        location.elements["remote"].text = @repository_urls[i]
        i += 1
      end

      @config = @config_doc.to_s
      update
    end

    # Set the repository browser location and update on Hudson server
    def repository_browser_location=(repository_browser_location)
      @repository_browser_location = repository_browser_location
      if @git
        @config_doc.elements['/project/scm/browser/url'].text = repository_browser_location
      else
        @config_doc.elements["/project/scm/browser/location"].text = repository_browser_location
      end
      @config = @config_doc.to_s
      update
    end

    # Set the job description and update on Hudson server
    def description=(description)
      @description = description
      @config_doc.elements["/project"] << REXML::Element.new("description") if @config_doc.elements["/project/description"].nil?

      @config_doc.elements["/project/description"].text = description
      @config = @config_doc.to_s
      update
    end

    def generate_trigger trigger, spec_text
      spec = REXML::Element.new("spec")
      spec.text = spec_text.to_s
      trigger.elements << spec
      trigger
    end
    private :generate_trigger

    def triggers= opts={}
      opts = {} if opts.nil?
      if triggers = @config_doc.elements["/project/triggers[@class='vector']"]
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
        # Todo: before calling update, @config need to be assigned with @config_doc.to_s,
        #       let it be done by update.
        @config = @config_doc.to_s
        update
      else
        $stderr.puts "triggers not found in configuration, triggers assignment ignored."
      end
    end

    def triggers
      @config_info_parser.triggers
    end

    #def url
    #  File.join( Hudson[:url], 'job', self.name) + '/'
    #end

    # Start building this job on Hudson server
    def build(params={})
      if @parameterized_job
        response = Hudson.client.build_job_with_parameters!(self.name, params)
      else
        response = Hudson.client.build_job!(self.name)
      end
      response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
    end

    def disable()
      response = Hudson.client.disable_job!(self.name)
      response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
    end

    def enable()
      response = Hudson.client.enable_job!(self.name)
      response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
    end

    # Delete this job from Hudson server
    def delete()
      response = Hudson.client.delete_job!(self.name)
      response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
    end

    def wipe_out_workspace()
      wait_for_build_to_finish

      if !active?
        response = send_post_request(@xml_api_wipe_out_workspace_path)
        response = Hudson.client.wipeout_job_workspace!(self.name)
      else
        response = false
      end
      response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
    end

  end
end
