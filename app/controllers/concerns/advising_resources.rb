module AdvisingResources

  GENERIC_LINK_CONFIG = [
    { feed_key: :uc_academic_progress_report, cs_link_key: 'UC_CX_APR_RPT'},
    { feed_key: :web_now_documents, cs_link_key: 'UC_CX_WEBNOW_ADVISOR_URI' },
    { feed_key: :uc_administrative_transcript, cs_link_key: 'UC_CX_ADM_TRANSCRIPT' },
    { feed_key: :uc_administrative_transcript_batch, cs_link_key: 'UC_CX_ADV_TSCRPT_BATCH'},
    { feed_key: :uc_advising_assignments, cs_link_key: 'UC_CX_STUDENT_ADVISOR' },
    { feed_key: :uc_appointment_system, cs_link_key: 'UC_CX_APPOINTMENT_ADV_MY_APPTS' },
    { feed_key: :uc_class_search, cs_link_key: 'UC_CX_CLASS_SEARCH' },
    { feed_key: :uc_eforms_action_center, cs_link_key: 'UC_CX_GT_ACTION_CENTER' },
    { feed_key: :uc_eforms_work_center, cs_link_key: 'UC_CX_GT_WORK_CENTER' },
    { feed_key: :uc_milestones, cs_link_key: 'UC_CX_AA_MILESTONE'},
    { feed_key: :uc_multi_year_academic_planner_generic, cs_link_key: 'UC_CX_PLANNER_ADV' },
    { feed_key: :uc_reporting_center, cs_link_key: 'UC_CX_REPORTING_CENTER' },
    { feed_key: :uc_service_indicators, cs_link_key: 'UC_CX_SERVICE_IND_DATA' },
    { feed_key: :uc_transfer_credit_report, cs_link_key: 'UC_CX_XFER_CREDIT_REPORT' },
    { feed_key: :uc_what_if_reports, cs_link_key: 'UC_CX_WHIF_RPT'},
    { feed_key: :uc_archived_transcripts, cs_link_key: 'UC_CX_ARCH_TSCRPT_ADVISOR'},
    { feed_key: :uc_change_course_load, cs_link_key: 'UC_CX_ADV_CHG_CRS_LOAD'},
    { feed_key: :uc_cross_campus_enroll_approval, cs_link_key: 'UC_CX_ADV_CRSCAMPENR_APRV'},
  ]

  def self.generic_links
    {
      feed: fetch_links(GENERIC_LINK_CONFIG)
    }
  end

  def self.student_specific_links(user_id)
    return {} unless (student_empl_id = empl_id user_id)

    student_career = (lookup_student_career user_id) || ''

    link_config = [
      { feed_key: :student_academic_progress_report, cs_link_key: 'UC_CX_APR_RPT_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
      { feed_key: :student_administrative_transcripts, cs_link_key: 'UC_CX_ADM_TRANSCRIPT_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
      { feed_key: :student_advising_assignments, cs_link_key: 'UC_CX_STUDENT_ADVISOR_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
      { feed_key: :student_advisor_notes, cs_link_key: 'UC_CX_SCI_NOTE_FLU', cs_link_params: { :EMPLID => student_empl_id } },
      { feed_key: :student_manage_milestones, cs_link_key: 'UC_CX_AA_MILESTONE_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
      { feed_key: :student_multi_year_academic_planner, cs_link_key: 'UC_CX_PLANNER_ADV_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
      { feed_key: :student_service_indicators, cs_link_key: 'UC_CX_SERVICE_IND_STDNT', cs_link_params: { :EMPLID => student_empl_id, :ACAD_CAREER => student_career} },
      { feed_key: :student_webnow_documents, cs_link_key: 'UC_CX_WEBNOW_STUDENT_URI', cs_link_params: { :EMPLID => student_empl_id } },
      { feed_key: :student_what_if_report, cs_link_key: 'UC_CX_WHIF_RPT_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
    ]

    {
      feed: fetch_links(link_config)
    }
  end

  def self.empl_id(user_id)
    User::Identifiers.lookup_campus_solutions_id user_id unless user_id.blank?
  end

  def self.lookup_student_career(user_id)
    return nil if user_id.blank?
    user = User::Current.new(user_id)
    User::Academics::TermPlans::TermPlans.new(user).latest_career_code
  end

  def self.fetch_links(link_config)
    links = {}
    link_config.try(:each) do |config|
      link_id = config.try(:[], :cs_link_key)
      link = LinkFetcher.fetch_link(link_id, config.try(:[], :cs_link_params)) unless link_id.blank?
      links[config.try(:[], :feed_key)] = link unless link.blank?
    end
    converted_links = HashConverter.camelize links
    converted_links
  end

end
