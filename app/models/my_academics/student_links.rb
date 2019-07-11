module MyAcademics
  class StudentLinks < UserSpecificModel
    include ClassLogger
    include LinkFetcher

    def merge(data)
      data[:studentLinks] = links
    end

    def links
      {
        tcReportLink: fetch_link('UC_CX_XFER_CREDIT_REPORT_STDNT'),
        waitlistsAndStudentOptions: fetch_link('UC_CX_WAITLIST_STDNT_OPTS'),
        waitlistReasonLink: fetch_link('UC_CX_WAITLIST_REASON_NOT_ENRL'),
        swapClassInfoLink: fetch_link('UC_CX_WAITLIST_SWAP'),
        waitListOtherCondition: fetch_link('UC_CX_WAITLIST_OTHER_CONDITION')
      }
    end
  end
end
