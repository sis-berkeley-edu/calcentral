module MyAcademics
  class StudentLinks
    include AcademicsModule
    include ClassLogger
    include LinkFetcher

    def merge(data)
      data[:studentLinks] = links
    end

    def links
      tcReportLink = fetch_link('UC_CX_XFER_CREDIT_REPORT_STDNT')
      {
        tcReportLink: tcReportLink
      }
    end
  end
end
