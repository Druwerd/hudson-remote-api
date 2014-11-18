module Hudson
  # This class provides an interface to Hudson jobs
  class Job
    attr_accessor :name, :config, :repository_url, :repository_urls, :repository_browser_location, :description, :parameterized_job

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
      @config = Hudson.client.job_config_info(self.name)
      @config_info_parser = Hudson::Parser::JobConfigInfo.new(@config)
      @config_writer = Hudson::XmlWriter::JobConfigInfo.new(self.name, @config)

      @info = Hudson.client.job_info(self.name)
      @job_info_parser = Hudson::Parser::JobInfo.new(@info)

      @description = @config_info_parser.description
      @parameterized_job = @config_info_parser.parameterized?
      @git = @config_info_parser.git_repo?
      @repository_url = @git ? @config_info_parser.git_repository : @config_info_parser.svn_repository
      @repostory_urls = @config_info_parser.svn_repository_urls
      @repository_browser_location = @config_info_parser.scm_broswer_location
    end
    alias :reload_config :load_config

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

    # Set the repository url and update on Hudson server
    def repository_url=(repository_url)
      #return false if @repository_url.nil?
      if @git
        @config_writer.git_repository_url = repository_url
      else
        @config_writer.svn_repository_url = repository_url
      end
      reload_config
    end

    def repository_urls=(repository_urls)
      @config_writer.repository_urls = repository_urls
      reload_config
    end

    # Set the repository browser location and update on Hudson server
    def repository_browser_location=(repository_browser_location)
      if @git
        @config_writer.git_repository_browser_location = repository_browser_location
      else
        @config_writer.svn_repository_browser_location = repository_browser_location
      end
      reload_config
    end

    # Set the job description and update on Hudson server
    def description=(description)
      @config_writer.description = description
      reload_config
    end

    def triggers= opts={}
      @config_writer.triggers = opts
      reload_config
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
