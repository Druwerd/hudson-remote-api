# This set of classes provides a Ruby interface to Hudson's web xml API
# 
# Author:: Dru Ibarra

require './lib/hudson-remote-api/config.rb'
require './lib/hudson-remote-api/hudson_object.rb'

Dir[File.dirname(__FILE__) + '/hudson-remote-api/*.rb'].each {|file| require file }
