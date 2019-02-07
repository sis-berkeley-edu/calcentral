module MyAcademics
  class StudentLinks < UserSpecificModel
    include ClassLogger
    include LinkFetcher

    def merge(data)
      data[:studentLinks] = links
    end

    def links
      tcReportLink = fetch_link('UC_CX_XFER_CREDIT_REPORT_STDNT')
      waitlistsAndStudentOptions = fetch_link('UC_CX_WAITLIST_STDNT_OPTS')
      {
        tcReportLink: tcReportLink,
        waitlistsAndStudentOptions: waitlistsAndStudentOptions,
      }
    end
  end
end
