module MyAcademics
  class AdvisorLinks
    include AcademicsModule
    include ClassLogger

    def merge(data)
      data[:advisorLinks] = links
    end

    def links
      campus_solutions_id = CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_campus_solutions_id
      tcReportLink = fetch_link('UC_CX_XFER_CREDIT_REPORT_ADVSR', { :EMPLID => campus_solutions_id })
      {
        tcReportLink: tcReportLink
      }
    end
  end
end
