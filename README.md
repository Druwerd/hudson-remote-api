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
# detects Hudson instance on your network & sets Hudson[:url]
Hudson.auto_config
```
Or

```ruby
# Manual Configuration
Hudson[:url] = 'http://localhost:8080'
Hudson[:user] = 'hudson'
Hudson[:password] = 'password'

# To turn off checking for crumbIssuer
Hudson[:crumb] = false
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

# job build indicator color
puts j.color

# get list of job's builds
puts j.builds_list

# latest build number
puts j.last_build

# latest successful build number
puts j.last_successful_build

# latest failed build number
puts j.last_failed_build

# view current triggers
# returns hash containing trigger name in key and trigger spec in value.
# Example: {"hudson.triggers.TimerTrigger"=>"0 22 * * *", "hudson.triggers.SCMTrigger"=>"* * * * *"}
puts j.triggers
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

