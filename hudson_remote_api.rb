# This set of classes provides a Ruby interface to Hudson's web xml API
# 
# Author:: Asdrubal Ibarra
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

if __FILE__ == $0
    #puts "All jobs:"
    #puts Hudson::Job.list
    
    #puts "Active jobs:"
    #puts Hudson::Job.list_active
    
    job = Hudson::Job.new('puppet-modules2')
    puts job.name
    puts job.description
    puts job.color
    puts job.last_build
    puts job.last_completed_build
    puts job.last_failed_build
    puts job.last_stable_build
    puts job.last_successful_build
    puts job.last_unsuccessful_build
    puts job.next_build_number
end