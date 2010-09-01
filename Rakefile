require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "hudson-remote-api"
    gemspec.summary = "Connect to Hudson's remote web API"
    gemspec.description = "Connect to Hudson's remote web API"
    gemspec.email = "Druwerd@gmail.com"
    gemspec.homepage = "http://github.com/Druwerd/hudson-remote-api"
    gemspec.authors = ["Dru Ibarra"]
    gemspec.rubyforge_project = gemspec.name
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }