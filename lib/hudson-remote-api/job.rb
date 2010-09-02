require 'hudson-remote-api'
module Hudson
    # This class provides an interface to Hudson jobs
    class Job < HudsonObject

        attr_accessor :name, :config, :repository_url, :repository_urls, :repository_browser_location, :description
        attr_reader :color, :last_build, :last_completed_build, :last_failed_build, :last_stable_build, :last_successful_build, :last_unsuccessful_build, :next_build_number
        
        # List all Hudson jobs
        def self.list()
            path = "#{HUDSON_URL_ROOT}/api/xml"
            xml = get_xml(path)
            
            jobs = []
            jobs_doc = REXML::Document.new(xml)
            jobs_doc.each_element("hudson/job") do |job|
                jobs << job.elements["name"].text
            end
            jobs
        end
        
        # List all jobs in active execution
        def self.list_active
            path = "#{HUDSON_URL_ROOT}/api/xml"
            xml = get_xml(path)
            
            active_jobs = []
            jobs_doc = REXML::Document.new(xml)
            jobs_doc.each_element("hudson/job") do |job|
                if job.elements["color"].text.include?("anime")
                    active_jobs << job.elements["name"].text
                end
            end
            active_jobs
        end
        
        def initialize(name)
            @name = name
            load_config
            load_info
        end
        
        # Load data from Hudson's Job configuration settings into class variables
        def load_config()
            path = "#{HUDSON_URL_ROOT}/job/#{@name}/config.xml"
            @config = get_xml(path)
            @config_doc = REXML::Document.new(@config)
            
            @config_doc = REXML::Document.new(@config)
            if !@config_doc.elements["/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation/remote"].nil?
                @repository_url = @config_doc.elements["/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation/remote"].text || ""
            end
            @repository_urls = []
            if !@config_doc.elements["/project/scm/locations"].nil?
                @config_doc.elements.each("/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation"){|e| @repository_urls << e.elements["remote"].text }
            end
            if !@config_doc.elements["/project/scm/browser/location"].nil?
                @repository_browser_location = @config_doc.elements["/project/scm/browser/location"].text
            end
            @description = @config_doc.elements["/project/description"].text || ""
        end
        
        def load_info()
            path = "#{HUDSON_URL_ROOT}/job/#{@name}/api/xml"
            @info = get_xml(path)
            @info_doc = REXML::Document.new(@info)
            
            if @info_doc.elements["/freeStylePorject"]
              @color = @info_doc.elements["/freeStyleProject/color"].text if @info_doc.elements["/freeStyleProject/color"]
              @last_build = @info_doc.elements["/freeStyleProject/lastBuild/number"].text if @info_doc.elements["/freeStyleProject/lastBuild/number"]
              @last_completed_build = @info_doc.elements["/freeStyleProject/lastCompletedBuild/number"].text if @info_doc.elements["/freeStyleProject/lastCompletedBuild/number"]
              @last_failed_build = @info_doc.elements["/freeStyleProject/lastFailedBuild/number"].text if @info_doc.elements["/freeStyleProject/lastFailedBuild/number"]
              @last_stable_build = @info_doc.elements["/freeStyleProject/lastStableBuild/number"].text if @info_doc.elements["/freeStyleProject/lastStableBuild/number"]
              @last_successful_build = @info_doc.elements["/freeStyleProject/lastSuccessfulBuild/number"].text if @info_doc.elements["/freeStyleProject/lastSuccessfulBuild/number"]
              @last_unsuccessful_build = @info_doc.elements["/freeStyleProject/lastUnsuccessfulBuild/number"].text if @info_doc.elements["/freeStyleProject/lastUnsuccessfulBuild/number"]
              @next_build_number = @info_doc.elements["/freeStyleProject/nextBuildNumber"].text if @info_doc.elements["/freeStyleProject/nextBuildNumber"]
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
            path = "#{HUDSON_URL_ROOT}/createItem"
            
            response = send_post_request(path, {:name=>new_job, :mode=>"copy", :from=>@name})
            raise(APIError, "Error copying job #{@name}: #{response.body}") if response.class != Net::HTTPFound
            Job.new(new_job)
        end
        
        # Update the job configuration on Hudson server
        def update(config=nil)
            @config = config if !config.nil?
            path = "#{HUDSON_URL_ROOT}/job/#{@name}/config.xml"
            response = send_xml_post_request(path, @config)
            response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end
        
        # Set the repository url and update on Hudson server
        def repository_url=(repository_url)
            return false if @repository_url.nil?
            @repository_url = repository_url
            @config_doc.elements["/project/scm/locations/hudson.scm.SubversionSCM_-ModuleLocation/remote"].text = repository_url
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
            @config_doc.elements["/project/scm/browser/location"].text = repository_browser_location
            @config = @config_doc.to_s
            update
        end
        
        # Set the job description and update on Hudson server
        def description=(description)
            @description = description
            @config_doc.elements["/project/description"].text = description
            @config = @config_doc.to_s
            update
        end
        
        # Start building this job on Hudson server (can't build parameterized jobs)
        def build()
            path = "#{HUDSON_URL_ROOT}/job/#{@name}/build"
            response = send_post_request(path, {:delay => '0sec'})
            response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end

        def disable()
            path = "#{HUDSON_URL_ROOT}/job/#{@name}/disable"
            response = send_post_request(path)
            puts response.class
            response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end
        
        def enable()
            path = "#{HUDSON_URL_ROOT}/job/#{@name}/enable"
            response = send_post_request(path)
            puts response.class
            response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end
        
        # Delete this job from Hudson server
        def delete()
            path  = "#{HUDSON_URL_ROOT}/job/#{@name}/doDelete"
            response = send_post_request(path)
            response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end
        
        def wipe_out_workspace()
            wait_for_build_to_finish
            path = "#{HUDSON_URL_ROOT}/job/#{@name}/doWipeOutWorkspace"
            if !active?
                response = send_post_request(path)
            else
                response = false
            end
            response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        end
    end
end