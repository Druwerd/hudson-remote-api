require File.dirname(__FILE__) + '/multicast.rb'

module Hudson

  class << self
    def client(config_settings={})
      @client ||= Client.new(config_settings)
    end
  end

  class Client
    attr_reader :configuration, :xml_api

    def initialize(config_settings={})
      @configuration = Hudson::Settings.new(config_settings).configuration
      @xml_api = Hudson::XmlApi.new(self.configuration)
      fetch_crumb
    end

    def auto_configure
      xml_response = Hudson.discover
      if xml_response
        mulitcast_parser = Hudson::Parser::Multicast.new(xml_response)
        self.configuration.host = mulitcast_parser.url || self.configuration.host
        self.configuration.version = mulitcast_parser.version || self.configuration.version
        puts "found Hudson version #{mulitcast_parser.version} @ #{mulitcast_parser.url}"
        return !mulitcast_parser.url.nil?
      end
    end

    def build_info(job_name, build_number)
      get_xml(self.xml_api.build_info_url(job_name, build_number))
    end

    def build_queue_info
      get_xml(self.xml_api.build_queue_info_url)
    end

    def build_job!(job_name, delay=0)
      send_post_request(self.xml_api.build_url(job_name), {:delay => "#{delay}sec"})
    end

    def build_job_with_parameters!(job_name, params, delay=0)
      send_post_request(self.xml_api.build_with_parameters_url(job_name), {:delay => "#{delay}sec"}.merge(params) )
    end

    def job_config_info(job_name)
      get_xml(self.xml_api.job_config_url(job_name))
    end

    def create_item!(params)
      send_post_request(self.xml_api.create_item_url, params)
    end

    def delete_job!(job_name)
      send_post_request(self.xml_api.delete_url(job_name))
    end

    def disable_job!(job_name)
      send_post_request(self.xml_api.disable_url(job_name))
    end

    def enable_job!(job_name)
      send_post_request(self.xml_api.enable_url(job_name))
    end

    def job_info(job_name)
      get_xml(self.xml_api.job_info_url(job_name))
    end

    def server_info
      get_xml(self.xml_api.server_info_url)
    end

    def update_job_config!(job_name, config)
      send_post_request(self.xml_api.job_config_url(job_name), config)
    end

    def wipeout_job_workspace!(job_name)
      send_post_request(self.xml_api.wipeout_workspace_url(job_name))
    end

    private
    def patch_bad_git_xml(xml)
      xml.gsub(/<(\/?)origin\/([_a-zA-Z0-9\-\.]+)>/, '<\1origin-\2>')
    end

    def http_class
      if self.configuration.proxy_host && self.configuration.proxy_port
        Net::HTTP::Proxy(self.configuration.proxy_host, self.configuration.proxy_port)
      else
        Net::HTTP
      end
    end

    def hudson_request(uri,request)
      http_class.start(uri.host, uri.port) do |http|
        http = http_class.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.request(request)
      end
    end

    def get_xml(url)
      uri = URI.parse(URI.encode(url))
      request = http_class::Get.new(uri.path).tap do |r|
        r.basic_auth(self.configuration.user, self.configuration.password) if self.configuration.user && self.configuration.password
        r['Content-Type'] = "text/xml"
      end
      
      response = hudson_request(uri,request)

      if response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        encoding = response.get_fields("Content-Encoding")
        if encoding and encoding.include?("gzip")
          return Zlib::GzipReader.new(StringIO.new(response.body)).read
        else
          return response.body
        end
      else
        $stderr.puts response.body
        raise APIError, "Error retrieving #{uri.path}"
      end
    end

    def send_post_request(url, data={})
      uri = URI.parse(URI.encode(url))
      request = http_class::Post.new(uri.path).tap do |r|
        r.basic_auth(self.configuration.user, self.configuration.password) if self.configuration.user && self.configuration.password
        r.set_form_data(data)
        r.add_field(crumb.name, crumb.value) if crumb
      end
      
      hudson_request(uri,request)
    end

    def crumb
      @@apiCrumb ||= nil
    end

    def fetch_crumb
      if self.configuration.crumb
        body = get_xml(self.xml_api.crumb_url)
        doc  = REXML::Document.new(body)

        crumbValue = doc.elements['/defaultCrumbIssuer/crumb'] or begin
          $stderr.puts "Failure fetching crumb value from server"
          return
        end

        crumbName = doc.elements['/defaultCrumbIssuer/crumbRequestField'] or begin
          $stderr.puts "Failure fetching crumb field name from server"
          return
        end

        @@apiCrumb = Struct.new(:name,:value).new(crumbName.text,crumbValue.text)
      end
    rescue
      $stderr.puts "Failure fetching crumb xml"
    end

  end
end