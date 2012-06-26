module Hudson
    # This class provides an interface to Hudson jobs
    class Job < HudsonObject

        attr_accessor :name, :config, :repository_url, :repository_urls, :repository_browser_location, :description
        attr_reader :color, :last_build, :last_completed_build, :last_failed_build, :last_stable_build, :last_successful_build, :last_unsuccessful_build, :next_build_number
        attr_reader :builds_list
        
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
              xml = get_xml(@@hudson_xml_api_path)

              jobs = []
              jobs_doc = REXML::Document.new(xml)
              jobs_doc.each_element("hudson/job") do |job|
                  jobs << job.elements["name"].text
              end
              jobs
          end
          
          # List all jobs in active execution
          def list_active
              xml = get_xml(@@hudson_xml_api_path)

              active_jobs = []
              jobs_doc = REXML::Document.new(xml)
              jobs_doc.each_element("hudson/job") do |job|
                  if job.elements["color"].text.include?("anime")
                      active_jobs << job.elements["name"].text
                  end
              end
              active_jobs
          end
          
          def get(job_name)
            job_name.strip!
            if list.include?(job_name)
              Job.new(job_name)
            else
              nil
            end
          end
          
          def create(name, config=nil)
            config = File.open(File.dirname(__FILE__) + '/new_job_config.xml').read if config.nil?

            response = send_post_request(@@xml_api_create_item_path, {:name=>name, :mode=>"hudson.model.FreeStyleProject", :config=>config})
            raise(APIError, "Error creating job #{name}: #{response.body}") if response.class != Net::HTTPFound
            Job.get(name)
          end
          
        end

        # Instance methods
        def initialize(name, config=nil)
            name.strip!
            Hudson::Job.fetch_crumb
            if Job.list.include?(name) # job already in Jenkins
              @name = name
              load_xml_api
              load_config
              load_info
              self
            else
              j = Job.create(name, config)
              @name = j.name
              load_xml_api
              load_config
              load_info
              self
            end
        end
        
        def load_xml_api
          @xml_api_path = File.join(Hudson[:url], "job/#{@name}/api/xml")
          @xml_api_config_path = File.join(Hudson[:url], "job/#{@name}/config.xml")
          @xml_api_build_path = File.join(Hudson[:url], "job/#{@name}/build")
          @xml_api_disable_path = File.join(Hudson[:url], "job/#{@name}/disable")
          @xml_api_enable_path = File.join(Hudson[:url], "job/#{@name}/enable")
          @xml_api_delete_path  = File.join(Hudson[:url], "job/#{@name}/doDelete")
          @xml_api_wipe_out_workspace_path = File.join(Hudson[:url], "job/#{@name}/doWipeOutWorkspace")
        end
        
        # Load data from Hudson's Job configuration settings into class variables
        def load_config
            @config = get_xml(@xml_api_config_path)
            @config_doc = REXML::Document.new(@config)

            @repository_urls = []
            if @config_doc.elements["/project/description"]
                @description = @config_doc.elements["/project/description"].text || ""
            end

            if @config_doc.elements["/project/scm"].attributes['class'] == "hudson.plugins.git.GitSCM"
                @git = true
                @repository_url = {}
                if @config_doc.elements["/project/scm/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url"]
                    @repository_url[:url] = @config_doc.elements['/project/scm/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url'].text || ""
                end
                if @config_doc.elements['/project/scm/branches/hudson.plugins.git.BranchSpec/name']
                    @repository_url[:branch] = @config_doc.elements['/project/scm/branches/hudson.plugins.git.BranchSpec/name'].text || ""
                end
                if @config_doc.elements['/project/scm/browser/url']
                    @repository_browser_location = @config_doc.elements['/project/scm/browser/url'].text || ""
                end
            else
                if !@config_doc.elements["/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation/remote"].nil?
                    @repository_url = @config_doc.elements["/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation/remote"].text || ""
                end
                if !@config_doc.elements["/project/scm/locations"].nil?
                    @config_doc.elements.each("/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation"){|e| @repository_urls << e.elements["remote"].text }
                end
                if !@config_doc.elements["/project/scm/browser/location"].nil?
                    @repository_browser_location = @config_doc.elements["/project/scm/browser/location"].text
                end
            end
        end
        
        def load_info()
            @info = get_xml(@xml_api_path)
            @info_doc = REXML::Document.new(@info)
            
            if @info_doc.elements["/freeStyleProject"]
              @color = @info_doc.elements["/freeStyleProject/color"].text if @info_doc.elements["/freeStyleProject/color"]
              @last_build = @info_doc.elements["/freeStyleProject/lastBuild/number"].text if @info_doc.elements["/freeStyleProject/lastBuild/number"]
              @last_completed_build = @info_doc.elements["/freeStyleProject/lastCompletedBuild/number"].text if @info_doc.elements["/freeStyleProject/lastCompletedBuild/number"]
              @last_failed_build = @info_doc.elements["/freeStyleProject/lastFailedBuild/number"].text if @info_doc.elements["/freeStyleProject/lastFailedBuild/number"]
              @last_stable_build = @info_doc.elements["/freeStyleProject/lastStableBuild/number"].text if @info_doc.elements["/freeStyleProject/lastStableBuild/number"]
              @last_successful_build = @info_doc.elements["/freeStyleProject/lastSuccessfulBuild/number"].text if @info_doc.elements["/freeStyleProject/lastSuccessfulBuild/number"]
              @last_unsuccessful_build = @info_doc.elements["/freeStyleProject/lastUnsuccessfulBuild/number"].text if @info_doc.elements["/freeStyleProject/lastUnsuccessfulBuild/number"]
              @next_build_number = @info_doc.elements["/freeStyleProject/nextBuildNumber"].text if @info_doc.elements["/freeStyleProject/nextBuildNumber"]
            end
            
            if !@info_doc.elements["/freeStyleProject/build"].nil?
                @builds_list = []
                @info_doc.elements.each("/freeStyleProject/build"){|e| @builds_list << e.elements["number"].text }
            end
        end
        
        def active?
            Job.list_active.include?(@name)
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
            
            response = send_post_request(@@xml_api_create_item_path, {:name=>new_job, :mode=>"copy", :from=>@name})
            raise(APIError, "Error copying job #{@name}: #{response.body}") if response.class != Net::HTTPFound
            Job.new(new_job)
        end
        
        # Update the job configuration on Hudson server
        def update(config=nil)
            @config = config if !config.nil?
            response = send_xml_post_request(@xml_api_config_path, @config)
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

        def url
          File.join( Hudson[:url], 'job', name) + '/'
        end
        
        # Start building this job on Hudson server (can't build parameterized jobs)
        def build()
            response = send_post_request(@xml_api_build_path, {:delay => '0sec'})
            response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end

        def disable()            
            response = send_post_request(@xml_api_disable_path)
            response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end
        
        def enable()            
            response = send_post_request(@xml_api_enable_path)
            response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end
        
        # Delete this job from Hudson server
        def delete()
            response = send_post_request(@xml_api_delete_path)
            response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end
        
        def wipe_out_workspace()
            wait_for_build_to_finish
            
            if !active?
                response = send_post_request(@xml_api_wipe_out_workspace_path)
            else
                response = false
            end
            response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end
    end
end
