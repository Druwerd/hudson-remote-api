module Hudson
  class Build < HudsonObject
    attr_reader :number, :job, :revisions, :result, :culprit

    def initialize(job, build_number=nil)
      @job = Job.new(job) if job.kind_of?(String)
      @job = job if job.kind_of?(Hudson::Job)
      @number =  build_number || @job.last_build
      @revisions = {}
      @xml_api_build_info_path = File.join(Hudson[:url], "job/#{@job.name}/#{@number}/api/xml")
      load_build_info
    end

    private
    def load_build_info

      build_info_xml = patch_bad_git_xml(get_xml(@xml_api_build_info_path))
      build_info_doc = REXML::Document.new(build_info_xml)

      build_result_element = build_info_doc.elements["/freeStyleBuild/result"]
      @result = build_result_element.text if build_result_element.respond_to?(:text)
      
      if build_info_doc.elements["/freeStyleBuild/changeSet"]
        build_info_doc.elements.each("/freeStyleBuild/changeSet/revision") do |revision|
          @revisions[revision.elements["module"].text] = revision.elements["revision"].text 
        end
      end

      culprit_element = build_info_doc.elements['/freeStyleBuild/culprit/fullName']
      @culprt = culprit_element.text if culprit_element.respond_to?(:text)

    end

    def patch_bad_git_xml(xml)
      xml.gsub(/<(\/?)origin\/([_a-zA-Z0-9\-\.]+)>/, '<\1origin-\2>')
    end
  end
end
