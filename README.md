[![Build Status](https://secure.travis-ci.org/Druwerd/hudson-remote-api.png)](http://travis-ci.org/Druwerd/hudson-remote-api)
# hudson-remote-api
hudson-remote-api is ruby library to talk to Hudson's xml remote access api

## Installation:

    gem install hudson-remote-api

## Configuration:

```ruby
require 'hudson-remote-api'
```

```ruby
# Auto Configuration 
# detects Hudson instance on your network & sets the host name
Hudson.auto_configure
```
Or

```ruby
# Manual Configuration
settings = {
      :host => 'http://localhost:8080', 
      :user => 'hudson', 
      :password => 'password', 
      :version => '1.0', 
      :crumb => true, # To turn on/off checking for crumbIssuer
      :proxy_host => 'your-proxy-host', # To turn on proxy access
      :proxy_port => 888
    }
Hudson.client(settings)

```
## Usage:

### List jobs
```ruby
# list all jobs
Hudson::Job.list

# list current active jobs
Hudson::Job.list_active
```

### Build Queue
```ruby
# list all jobs in the build queue (waiting to run)
Hudson::BuildQueue.list
```

### Create (or load existing) job
```ruby
j = Hudson::Job.new('my_new_job')
```

### Actions on a job
```ruby
j = Hudson::Job.new('my_new_job')

# start a build
j.build

# start a parameterized build. Pass parameters as a Hash.
j.build({ :awesome_dev => "thomasbiddle" })

# create a copy of existing job
j.copy('copy_of_my_job')

# disable the job
j.disable

# enable the job
j.enable

# clear out the job's workspace
j.wipe_out_workspace

# wait (sleep) until the job has completed building
j.wait_for_build_to_finish

# delete the job
j.delete
```

### Information on a job 
```ruby
j = Hudson::Job.new('job_name')

# job's current build indicator color
puts j.color

# returns true if job is currently running
j.active?

# list of job's build numbers
puts j.builds_list

# latest build number
puts j.last_build

# latest successful build number
puts j.last_successful_build

# latest failed build number
puts j.last_failed_build

# next build number
puts j.next_build_number

# view current triggers
# returns hash containing trigger name in key and trigger spec in value.
# Example: {"hudson.triggers.TimerTrigger"=>"0 22 * * *", "hudson.triggers.SCMTrigger"=>"* * * * *"}
j.triggers
```

### Information on a build
```ruby
# gets information on latest build
b = Hudson::Build.new('job_name')

# gets information on particular build number
b = Hudson::Build.new('job_name', 42)

# get commit revisions in this build
puts b.revisions

# get the result of this build
puts b.result

# get the culprit of this build
puts b.culprit
```

### Modifying a job

#### Set job description
```ruby
j.description = "My new job description"
```

#### Set repository
```ruby
# Git
j.repository_url = { :url => 'https://github.com/beeplove/hudson-remote-api-mkhan.git', :branch => 'origin/master' }
# or, only to change branch
j.repository_url = { :branch => 'origin/master' }

# SVN
j.repository_url = "http://svn.myrepo.com"
```

#### Set build triggers
```ruby
j.triggers = { 'hudson.triggers.SCMTrigger' => '* * * * *'}
# or, using shortcut
j.triggers = { 'SCMTrigger' => '* * * * *', 'TimerTrigger' => '0 22 * * *'}

# Add or update a trigger in existing triggers*
j.triggers = j.triggers.merge({ 'hudson.triggers.TimerTrigger' => '0 22 * * *'})

# Delete existing triggers
j.triggers = {}
# or,
j.triggers = nil

```
*Avoid using shortcut form when editing a trigger in existing triggers

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
