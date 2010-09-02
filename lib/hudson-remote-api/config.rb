require File.dirname(__FILE__) + '/multicast.rb'

module Hudson
  def self.config
    # set defaults
    @@settings = {:host => 'localhost', :url_root => '/', :port => 80, :user => nil, :password => nil}
    
    xml_response = discover()
    if xml_response
      #puts xml_response
      doc = REXML::Document.new(xml_response)
      Hudson[:host] = doc.elements["/hudson/url"].text
      Hudson[:version] = doc.elements["/hudson/version"].text
      puts "found Hudson version #{Hudson[:version]} @ #{Hudson[:host]}"
    end
  end
  
  def self.[](param)
    return @@settings[param]
  end

  def self.[]=(param,value)
    @@settings[param]=value
  end

  def self.settings=(settings)
    @@settings = settings
  end
end
