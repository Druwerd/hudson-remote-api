require File.dirname(__FILE__) + '/multicast.rb'

module Hudson
  # set default settings
  @@settings = {
    :url => 'http://localhost:8080', 
    :user => nil, 
    :password => nil, 
    :version => nil, 
    :crumb => true,
    :proxy_host => nil,
    :proxy_port => nil
  }
  
  def self.[](param)
    return @@settings[param]
  end

  def self.[]=(param,value)
    param = param.to_sym if param.kind_of?(String)
    if param == :host or param == :url
      value = "http://#{value}" if value !~ /https?:\/\//
      @@settings[:url] = value
    else
      @@settings[param]=value
    end
    HudsonObject::load_xml_api
    BuildQueue::load_xml_api
  end

  def self.settings=(settings)
    if settings.kind_of?(Hash)
      settings.each do |param, value|
        Hudson[param] = value
      end
    end
  end
  
  # Discovers nearby Hudson server on the network and configures settings
  def self.auto_config
    xml_response = discover()
    if xml_response
      doc = REXML::Document.new(xml_response)
      url = doc.elements["/hudson/url"]
      if url
        Hudson[:url] = url.text
        Hudson[:version] = doc.elements["/hudson/version"].text
        puts "found Hudson version #{Hudson[:version]} @ #{Hudson[:url]}"
        return true
      end
    end
  end
  
end
