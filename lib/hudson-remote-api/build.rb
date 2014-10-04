module Hudson
  class Build < HudsonObject
    attr_reader :number, :job, :revisions, :result, :culprit

    def initialize(job, build_number=nil)
      @job = Job.new(job) if job.kind_of?(String)
      @job = job if job.kind_of?(Hudson::Job)
      if build_number
        @number = build_number
      else
        @number = @job.last_build
      end
      @revisions = {}
      @xml_api_build_info_path = File.join(Hudson[:url], "job/#{@job.name}/#{@number}/api/xml")
      load_build_info
    end

    private
    def load_build_info

      build_info_xml = patch_bad_git_xml(get_xml(@xml_api_build_info_path))
      build_info_doc = REXML::Document.new(build_info_xml)

      if build_info_doc.elements["/freeStyleBuild/result"]
        @result = build_info_doc.elements["/freeStyleBuild/result"].text
      end
      if !build_info_doc.elements["/freeStyleBuild/changeSet"].nil?
        build_info_doc.elements.each("/freeStyleBuild/changeSet/revision"){|e| @revisions[e.elements["module"].text] = e.elements["revision"].text }
      end

      if build_info_doc.elements['/freeStyleBuild/culprit/fullName']
        @culprit = build_info_doc.elements['/freeStyleBuild/culprit/fullName'].text
      end

    end

    def patch_bad_git_xml(xml)
      xml.gsub(/<(\/?)origin\/([_a-zA-Z0-9\-\.]+)>/, '<\1origin-\2>')
    end
  end
end
