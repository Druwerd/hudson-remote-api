module Hudson
  # Base class for all Hudson objects
  class HudsonObject

    class << self
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

      def http_class
        if Hudson[:proxy_host] && Hudson[:proxy_port]
          Net::HTTP::Proxy(Hudson[:proxy_host], Hudson[:proxy_port])
        else
          Net::HTTP
        end
      end

      def load_xml_api
        @@hudson_xml_api_path = File.join(Hudson[:url], "api/xml")
        @@xml_api_create_item_path = File.join(Hudson[:url], "createItem")
      end

      def url_for(path)
        File.join Hudson[:url], path
      end

      def get_xml(url)
        uri = URI.parse(URI.encode(url))
        request = http_class::Get.new(uri.path).tap do |r|
          r.basic_auth(Hudson[:user], Hudson[:password]) if Hudson[:user] and Hudson[:password]  
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
          r.basic_auth(Hudson[:user], Hudson[:password]) if Hudson[:user] and Hudson[:password]
          r.set_form_data(data)
          r.add_field(crumb.name, crumb.value) if crumb
        end
        
        hudson_request(uri,request)
      end

      def send_xml_post_request(url, xml, data=nil)
        uri = URI.parse(URI.encode(url))
        path = uri.query ? "#{uri.path}?#{uri.query}" : uri.path
        request = http_class::Post.new(path).tap do |r|
          r.basic_auth(Hudson[:user], Hudson[:password]) if Hudson[:user] and Hudson[:password]
          r.set_form_data(data) if data
          r.add_field(crumb.name, crumb.value) if crumb
          r.body = xml
        end
        
        hudson_request(uri,request)
      end

      def crumb
        @@apiCrumb ||= nil
      end

      def fetch_crumb
        if Hudson[:crumb]
          body = get_xml(url_for '/crumbIssuer/api/xml')
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

    load_xml_api

    def get_xml(path)
      self.class.get_xml(path)
    end

    def send_post_request(url, data={})
      self.class.send_post_request(url, data)
    end

    def send_xml_post_request(url, xml, data=nil)
      self.class.send_xml_post_request(url, xml, data)
    end

  end
end