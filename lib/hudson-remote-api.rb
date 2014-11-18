require 'uri'
require 'net/http'
require './lib/hudson-remote-api/client.rb'

Dir[File.dirname(__FILE__) + '/hudson-remote-api/**/*.rb'].each {|file| require file }
