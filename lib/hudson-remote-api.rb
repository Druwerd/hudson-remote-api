# This set of classes provides a Ruby interface to Hudson's web xml API
# 
# Author:: Asdrubal Ibarra

require 'net/http'
require 'rexml/document'
require 'cgi'
require 'yaml'
require 'zlib'

module Hudson
  @@settings = {:host => 'localhost', :port => 80, :user => nil, :password => nil}

  def self.[](param)
    return @@settings[param]
  end

  def self.[]=(param,value)
    @@settings[param]=value
  end

  def self.settings=(settings)
    @@settings = settings
  end

  HUDSON_URL_ROOT = ""
  # Base class for all Hudson objects
  class HudsonObject

    def self.get_xml(path)
      request = Net::HTTP::Get.new(path)
      request.basic_auth(Hudson[:user], Hudson[:password]) if Hudson[:user] and Hudson[:password]
      request['Content-Type'] = "text/xml"
      response = Net::HTTP.start(Hudson[:host], Hudson[:port]){|http| http.request(request)}

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
      request.basic_auth(Hudson[:user], Hudson[:password]) if Hudson[:user] and Hudson[:password]
      request.set_form_data(data)
      #puts request.to_yaml
      Net::HTTP.new(Hudson[:host], Hudson[:port]).start{|http| http.request(request)}
    end

    def send_xml_post_request(path, xml)
      request = Net::HTTP::Post.new(path)
      request.basic_auth(Hudson[:user], Hudson[:password]) if Hudson[:user] and Hudson[:password]
      request.body = xml
      #puts request.body
      #puts request.to_yaml
      Net::HTTP.new(Hudson[:host], Hudson[:port]).start{|http| http.request(request)}
    end
  end
end

Dir[File.dirname(__FILE__) + '/hudson-remote-api/*.rb'].each {|file| require file }