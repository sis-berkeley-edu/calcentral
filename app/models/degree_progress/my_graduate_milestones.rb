module DegreeProgress
  class MyGraduateMilestones < UserSpecificModel
    # This model provides a student-specific version of milestone data for GRAD and LAW career.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include MilestonesModule
    include LinkFetcher

    APR_LINK_ID_HAAS = 'UC_CX_APR_RPT_GRD_STDNT_HAAS'
    APR_LINK_ID_LAW = 'UC_CX_APR_RPT_GRD_STDNT_LAW'
    APR_LINK_ID_GRAD = 'UC_CX_APR_RPT_GRD_STDNT'

    def get_feed_internal
      return {} unless is_feature_enabled? && target_audience?
      response = CampusSolutions::DegreeProgress::GraduateMilestones.new(user_id: @uid).get
      if response[:errored] || response[:noStudentId]
        response[:feed] = {}
      else
        response[:feed] = {
          degree_progress: process(response)
        }
        response[:feed][:links] = get_links
      end
      HashConverter.camelize response
    end

    private

    def get_links
      roles = MyAcademics::MyAcademicRoles.new(@uid).get_feed
      student_empl_id = User::Identifiers.lookup_campus_solutions_id @uid
      links = {}

      links[:academic_progress_report_haas] = fetch_link(APR_LINK_ID_HAAS, { :EMPLID => student_empl_id }) if haas_student?(roles[:current])
      links[:academic_progress_report_law] = fetch_link(APR_LINK_ID_LAW, { :EMPLID => student_empl_id }) if law_student?(roles[:current])
      links[:academic_progress_report_grad] = fetch_link(APR_LINK_ID_GRAD, { :EMPLID => student_empl_id }) if non_haas_grad_student?(roles[:current])
      links
    end

    def haas_student?(roles)
      !!roles['haasBusinessAdminMasters'] || !!roles['haasBusinessAdminPhD']
    end

    def law_student?(roles)
      !!roles['doctorScienceLaw'] || !!roles['jurisSocialPolicyMasters'] || !!roles['jurisSocialPolicyPhC'] || !!roles['jurisSocialPolicyPhD'] || !!roles['lawJdCdp']
    end

    def non_haas_grad_student?(roles)
      !!roles['grad'] && (!roles['haasBusinessAdminMasters'] && !roles['haasBusinessAdminPhD'] && !roles['haasFullTimeMba'] && !roles['haasEveningWeekendMba'] && !roles['haasExecMba'] && !roles['haasMastersFinEng'] && !roles['haasMbaPublicHealth'] && !roles['haasMbaJurisDoctor'])
    end

    def target_audience?
      User::SearchUsersByUid.new(id: @uid, roles: [:graduate, :law, :exStudent]).search_users_by_uid.present?
    end

    def is_feature_enabled?
      Settings.features.cs_degree_progress_grad_student
    end
  end
end
