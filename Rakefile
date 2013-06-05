require 'rubygems'
require 'rake'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "hudson-remote-api"
    gemspec.summary = "Connect to Hudson's remote web API"
    gemspec.description = "Connect to Hudson's remote web API"
    gemspec.email = "Druwerd@gmail.com, guy.xtafcusqt@gmail.com"
    gemspec.homepage = "https://github.com/GuyCheung/hudson-remote-api"
    gemspec.authors = ["Dru Ibarra", "Guy Cheung"]
    gemspec.rubyforge_project = gemspec.name
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

Rake::TestTask.new do |t|
 t.libs << 'test'
end

desc "Run tests"
task :default => :test
