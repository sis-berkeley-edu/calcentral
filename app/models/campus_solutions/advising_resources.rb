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
      links = (resources = feed['UC_ADVISING_RESOURCES']) && resources['UC_ADVISING_LINKS']

      if links
        # The following links are hard-coded, for now. Ideally they would be served by CS API but there is an urgent need
        # thus we manage the content via CalCentral settings.
        add_cs_link links, :eforms_center, 'EFORMS_CENTER', 'eForms Center'
        add_cs_link links, :eforms_work_list, 'EFORMS_WORK_LIST', 'eForms Work List'
        add_cs_link links, :web_now_documents, 'WEB_NOW_DOCUMENTS', 'WebNow Documents'
        add_cs_link links, :multi_year_academic_planner_generic, 'MULTI_YEAR_ACADEMIC_PLANNER_GENERIC', 'Multi-Year Planner'
        add_cs_link links, :multi_year_academic_planner, 'MULTI_YEAR_ACADEMIC_PLANNER_STUDENT_SPECIFIC', 'Multi-Year Planner', "?UCemplid=#{lookup_student_id}"
        add_cs_link links, :schedule_planner, 'SCHEDULE_PLANNER_STUDENT_SPECIFIC', 'Schedule Planner', "?EMPLID=#{lookup_student_id}"
        
        # LINK-API CALLS
        advisor_notes_link = fetch_link('UC_CX_SCI_NOTE_FLU', {
          :EMPLID => "#{@campus_solutions_id}"
        })
        if advisor_notes_link
          links[:uc_advisor_notes] = advisor_notes_link
        end

        appointment_system_link = fetch_link('UC_CX_APPOINTMENT_ADV_SETUP', {
          :EMPLID => "#{@campus_solutions_id}"
        })
        if appointment_system_link
          links[:uc_appointment_system] = appointment_system_link
        end

        # STUDENT-SPECIFIC LINKS
        if @student[:campus_solutions_id]
          student_appointments_link = fetch_link('UC_CX_APPOINTMENT_STD_MY_APPTS', {
            :EMPLID => @student[:campus_solutions_id]
          })
          if student_appointments_link
            links[:student_appointments] = student_appointments_link
          end

          student_advisor_notes_link = fetch_link('UC_CX_SCI_NOTE_FLU', {
            :EMPLID => @student[:campus_solutions_id]
          })
          if student_advisor_notes_link
            links[:student_advisor_notes] = student_advisor_notes_link
          end

          student_webnow_documents_link = fetch_link('UC_CX_WEBNOW_STUDENT_URI', {
            :EMPLID => @student[:campus_solutions_id]
          })
          if student_webnow_documents_link
            links[:student_webnow_documents] = student_webnow_documents_link
          end
        end
      end
      feed
    end

    def fetch_link(link_key, placeholders)
      if (link_feed = CampusSolutions::Link.new.get_url(link_key, placeholders))
        link = link_feed.try(:[], :feed).try(:[], :link)
      end
      logger.error "Could not retrieve CS link #{link_key} for AdvisingResources feed, uid = #{@uid}" unless link
      link
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

    private

    def add_cs_link(links, config_key, link_key, name, params_string = '')
      value = Settings.campus_solutions_links.advising.send config_key
      if value
        links[link_key] = {
          'NAME' => name,
          'URL' => value + params_string,
          'IS_CS_LINK' => true
        }
      end
    end

  end
end
