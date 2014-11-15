module Hudson
  class XmlApi
    attr_accessor :host

    def initialize(configuration)
      self.host = configuration.host
    end

    def build_url(job_name)
      File.join(self.host, "job/#{job_name}/build")
    end

    def build_info_url(job_name, build_number)
      File.join(self.host, "job/#{job_name}/#{number}/api/xml")
    end

    def build_queue_info_url
      File.join(self.host, "queue/api/xml")
    end

    def build_with_parameters_url(job_name)
      File.join(self.host, "job/#{job_name}/buildWithParameters")
    end

    def create_item_url
      File.join(self.host, "createItem")
    end

    def crumb_url
      File.join(self.host, "/crumbIssuer/api/xml")
    end

    def delete_url(job_name)
      File.join(self.host, "job/#{job_name}/doDelete")
    end

    def disable_url(job_name)
      File.join(self.host, "job/#{job_name}/disable")
    end

    def enable_url(job_name)
      File.join(self.host, "job/#{job_name}/enable")
    end

    def job_info_url(job_name)
      File.join(self.host, "job/#{job_name}/api/xml")
    end

    def job_config_url(job_name)
      File.join(self.host, "job/#{job_name}/config.xml")
    end

    def server_info_url
      File.join(self.host, "api/xml")
    end

    def wipeout_workspace_url(job_name)
      File.join(self.host, "job/#{job_name}/doWipeOutWorkspace")
    end 
  end
end