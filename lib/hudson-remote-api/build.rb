module Hudson
  class Build
    attr_reader :number, :job, :revisions, :result, :culprit

    def initialize(job, build_number=nil)
      @job = Job.new(job) if job.kind_of?(String)
      @job = job if job.kind_of?(Hudson::Job)
      @number =  build_number || @job.last_build
      @revisions = {}
      load_build_info
    end

    private
    def load_build_info
      build_info_xml    = Hudson.client.build_info(self.job.name, self.number)
      build_info_parser = Hudson::Parse::BuildInfo.new(build_info_xml)

      @result    = build_info_parser.result
      @revisions = build_info_parser.revisions
      @culprit   = build_info_parser.culprit
    end

  end
end
