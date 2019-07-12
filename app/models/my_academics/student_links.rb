module MyAcademics
  class StudentLinks < UserSpecificModel
    include ClassLogger

    def merge(data)
      data[:studentLinks] = links
    end

    def links
      {
        tcReportLink: LinkFetcher.fetch_link('UC_CX_XFER_CREDIT_REPORT_STDNT'),
        waitlistsAndStudentOptions: LinkFetcher.fetch_link('UC_CX_WAITLIST_STDNT_OPTS'),
        academicGuideGradesPolicy: LinkFetcher.fetch_link('UC_CX_ACAD_GUIDE_GRADES'),
        waitlistReasonLink: LinkFetcher.fetch_link('UC_CX_WAITLIST_REASON_NOT_ENRL'),
        swapClassInfoLink: LinkFetcher.fetch_link('UC_CX_WAITLIST_SWAP')
      }
    end
  end
end
