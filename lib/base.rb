require 'net/http'
require 'rexml/document'
require 'cgi'
require 'yaml'
require 'zlib'

require File.dirname(__FILE__) + '/errors.rb'

module Hudson
    HUDSON_SETTINGS_FILE = File.dirname(__FILE__) + "/../hudson_settings.yml"
    HUDSON_URL_ROOT = ""
    # Base class for all Hudson objects
    class HudsonObject
        @@settings = YAML::load(File.open(HUDSON_SETTINGS_FILE))
        @@host = @@settings['host'] || 'localhost'
        @@port = @@settings['port'] || 80
        @@user = @@settings['user'] || nil
        @@password = @@settings['password'] || nil
        
        def self.get_xml(path)
            request = Net::HTTP::Get.new(path)
            request.basic_auth(@@user, @@password) if @@user and @@password
            request['Content-Type'] = "text/xml"
            response = Net::HTTP.start(@@host, @@port){|http| http.request(request)}
            
            if response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
                encoding = response.get_fields("Content-Encoding")
                if encoding and encoding.include?("gzip")
                    return Zlib::GzipReader.new(StringIO.new(response.body)).read
                else
                    return response.body
                end
            else
                puts response
                raise APIError, "Error retrieving #{path}"
            end
        end
        
        def get_xml(path)
            self.class.get_xml(path)
        end
        
        def send_post_request(path, data={})
            request = Net::HTTP::Post.new(path)
            request.basic_auth(@@user, @@password) if @@user and @@password
            request.set_form_data(data)
            #puts request.to_yaml
            Net::HTTP.new(@@host, @@port).start{|http| http.request(request)}
        end
        
        def send_xml_post_request(path, xml)
            request = Net::HTTP::Post.new(path)
            request.basic_auth(@@user, @@password) if @@user and @@password
            request.body = xml
            #puts request.body
            #puts request.to_yaml
            Net::HTTP.new(@@host, @@port).start{|http| http.request(request)}
        end
    end
end