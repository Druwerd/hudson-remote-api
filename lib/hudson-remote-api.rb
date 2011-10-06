# This set of classes provides a Ruby interface to Hudson's web xml API
# 
# Author:: Dru Ibarra

require 'net/http'
require "net/https"
require 'uri'
require 'rexml/document'
require 'cgi'
require 'yaml'
require 'zlib'
require File.dirname(__FILE__) + '/hudson-remote-api/config.rb'

module Hudson
  # Base class for all Hudson objects
  class HudsonObject
    
    
    def self.load_xml_api
      @@hudson_xml_api_path = File.join(Hudson[:url], "api/xml")
      @@xml_api_create_item_path = File.join(Hudson[:url], "createItem")
    end
    
    load_xml_api
    
    def self.get_xml(url)
      uri = URI.parse(URI.encode(url))
      host = uri.host
      port = uri.port
      path = uri.path
      request = Net::HTTP::Get.new(path)
      request.basic_auth(Hudson[:user], Hudson[:password]) if Hudson[:user] and Hudson[:password]
      request['Content-Type'] = "text/xml"
      response = Net::HTTP.start(host, port) do |http| 
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.request(request)
      end

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

    def self.send_post_request(url, data={})
      uri = URI.parse(URI.encode(url))
      host = uri.host
      port = uri.port
      path = uri.path
      request = Net::HTTP::Post.new(path)
      request.basic_auth(Hudson[:user], Hudson[:password]) if Hudson[:user] and Hudson[:password]
      request.set_form_data(data)
      Net::HTTP.new(host, port).start{|http| http.request(request)}
    end
    
    def send_post_request(url, data={})
      self.class.send_post_request(url, data)
    end

    def self.send_xml_post_request(url, xml, data=nil)
      uri = URI.parse(URI.encode(url))
      host = uri.host
      port = uri.port
      path = uri.path
      path = path+"?"+uri.query if uri.query
      request = Net::HTTP::Post.new(path)
      request.basic_auth(Hudson[:user], Hudson[:password]) if Hudson[:user] and Hudson[:password]
      request.set_form_data(data) if data
      request.body = xml
      Net::HTTP.new(host, port).start{|http| http.request(request)}
    end
    
    def send_xml_post_request(url, xml, data=nil)
      self.class.send_xml_post_request(url, xml, data)
    end
  end
end

Dir[File.dirname(__FILE__) + '/hudson-remote-api/*.rb'].each {|file| require file }