module CampusSolutions
  class AdvisingResources < CachedProxy

    include CampusSolutionsIdRequired
    include Cache::RelatedCacheKeyTracker

    def initialize(options = {})
      @student = {
        uid: options[:student_uid]
      }
      super options
    end

    def get_internal
      lookup_student_id
      if @student[:uid] && !@student[:campus_solutions_id]
        logger.info "Lookup of campus_solutions_id for uid #{@student[:uid]} failed, cannot call Campus Solutions API"
        {
          noStudentId: true
        }
      else
        super
      end
    end

    def lookup_student_id
      if @student[:uid]
        @student[:campus_solutions_id] = CalnetCrosswalk::ByUid.new(user_id: @student[:uid]).lookup_campus_solutions_id
      end
    end

    def build_feed(response)
      return {} unless response && (feed = response['ROOT'])
      # TODO: remove dependency on legacy advising links API
      # Use this for legacy links
      links = feed.fetch('UC_ADVISING_RESOURCES').fetch('UC_ADVISING_LINKS', {})

      # Use this for CS Link API urls.
      cs_links = {}

      advising_link_settings = [
        # advisors see these on advisor-specific views
        { feed_key: :uc_academic_progress_report, cs_link_key: 'UC_CX_APR_RPT'},
        { feed_key: :web_now_documents, cs_link_key: 'UC_CX_WEBNOW_ADVISOR_URI' },
        { feed_key: :uc_administrative_transcript, cs_link_key: 'UC_CX_ADM_TRANSCRIPT' },
        { feed_key: :uc_advising_assignments, cs_link_key: 'UC_CX_STUDENT_ADVISOR' },
        { feed_key: :uc_appointment_system, cs_link_key: 'UC_CX_APPOINTMENT_ADV_MY_APPTS' },
        { feed_key: :uc_class_search, cs_link_key: 'UC_CX_CLASS_SEARCH' },
        { feed_key: :uc_eforms_action_center, cs_link_key: 'UC_CX_GT_ACTION_CENTER' },
        { feed_key: :uc_eforms_work_center, cs_link_key: 'UC_CX_GT_WORK_CENTER' },
        { feed_key: :uc_milestones, cs_link_key: 'UC_CX_AA_MILESTONE'},
        { feed_key: :uc_multi_year_academic_planner_generic, cs_link_key: 'UC_CX_PLANNER_ADV' },
        { feed_key: :uc_reporting_center, cs_link_key: 'UC_CX_REPORTING_CENTER' },
        { feed_key: :uc_service_indicators, cs_link_key: 'UC_CX_SERVICE_IND_DATA' },
        { feed_key: :uc_transfer_credit_report, cs_link_key: 'UC_CX_CSU_DA_TRN_CDT' },
        { feed_key: :uc_what_if_reports, cs_link_key: 'UC_CX_WHIF_RPT'}
      ]

      advising_link_settings.each do |setting|
        link = fetch_link(setting[:cs_link_key], setting[:cs_link_params])
        cs_links[setting[:feed_key]] = link unless link.blank?
      end

      student_empl_id = @student[:campus_solutions_id]

      if student_empl_id
        # advisors and students see these on student-specific views

        advising_student_link_settings = [
          { feed_key: :student_academic_progress_report, cs_link_key: 'UC_CX_APR_RPT_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
          { feed_key: :student_administrative_transcripts, cs_link_key: 'UC_CX_ADM_TRANSCRIPT_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
          { feed_key: :student_advising_assignments, cs_link_key: 'UC_CX_STUDENT_ADVISOR_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
          { feed_key: :student_advisor_notes, cs_link_key: 'UC_CX_SCI_NOTE_FLU', cs_link_params: { :EMPLID => student_empl_id } },
          { feed_key: :student_manage_milestones, cs_link_key: 'UC_CX_AA_MILESTONE_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
          { feed_key: :student_multi_year_academic_planner, cs_link_key: 'UC_CX_PLANNER_ADV_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
          # TODO refactor the model to acquire the student's `academicStatus.studentCareer.academicCareer.code`, based on effective (most recent) date - `academicStatus.studentCareer.fromDate`.
          # This entry is hacked with an empty ACAD_CAREER parameter in order to work correctly on Campus Solutions.
          { feed_key: :student_service_indicators, cs_link_key: 'UC_CX_SERVICE_IND_STDNT', cs_link_params: { :EMPLID => student_empl_id, :ACAD_CAREER => '' } },
          { feed_key: :student_webnow_documents, cs_link_key: 'UC_CX_WEBNOW_STUDENT_URI', cs_link_params: { :EMPLID => student_empl_id } },
          { feed_key: :student_what_if_report, cs_link_key: 'UC_CX_WHIF_RPT_STDNT', cs_link_params: { :EMPLID => student_empl_id } },
        ]

        advising_student_link_settings.each do |setting|
          link = fetch_link(setting[:cs_link_key], setting[:cs_link_params])
          cs_links[setting[:feed_key]] = link unless link.blank?
        end
      end

      {
        links: links,
        cs_links: cs_links
      }
    end

    def fetch_link(link_key, placeholders = {})
      CampusSolutions::Link.new.get_url(link_key, placeholders).try(:[], :link)
    end

    def instance_key
      [@uid, @student[:uid]].compact.join '-'
    end

    def url
      "#{@settings.base_url}/UC_AA_ADVISING_RESOURCES.v1/UC_ADVISING_RESOURCES?EMPLID=#{@campus_solutions_id}".tap do |url|
        url << "&STUDENT_EMPLID=#{@student[:campus_solutions_id]}" if @student[:campus_solutions_id]
      end
    end

    def xml_filename
      'advising_resources.xml'
    end

  end
end
