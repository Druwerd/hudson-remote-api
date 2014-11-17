# This set of classes provides a Ruby interface to Hudson's web xml API
# 
# Author:: Dru Ibarra

require './lib/hudson-remote-api/client.rb'

Dir[File.dirname(__FILE__) + '/hudson-remote-api/**/*.rb'].each {|file| require file }
