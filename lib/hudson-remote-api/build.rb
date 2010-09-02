require 'hudson-remote-api'
module Hudson
	class Build < HudsonObject
		attr_reader :number, :job, :revisions, :result
		
		def initialize(job, build_number=nil)
			@job = Job.new(job) if job.kind_of?(String)
			@job = job if job.kind_of?(Hudson::Job)
			if build_number
				@number = build_number
			else
				@number = @job.last_build
			end
			@revisions = {}
			load_build_info
		end
		
		private
		def load_build_info
			path = "#{Hudson[:url_root]}/job/#{@job.name}/#{@number}/api/xml"
			build_info_xml = get_xml(path)
            build_info_doc = REXML::Document.new(build_info_xml)
			
            if !build_info_doc.elements["/freeStyleBuild/changeSet"].nil?
                build_info_doc.elements.each("/freeStyleBuild/changeSet/revision"){|e| @revisions[e.elements["module"].text] = e.elements["revision"].text }
            end
		end
	end
end