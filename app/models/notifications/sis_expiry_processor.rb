module Notifications
  class SisExpiryProcessor
    include ClassLogger

    def process(event, timestamp)
      return false unless accept? event
      logger.debug "Processing event: #{event}; timestamp = #{timestamp}"
      if (expiry_module = get_expiry event)
        if (uid = (event['topic'] == 'sis:faculty:grade-roster') ? (get_instructor_uids event) : (get_uid event))
        expiry_module.expire uid
        end
      else
        logger.warn "Event topic #{event['topic']} not recognized"
      end
    end

    private

    def accept?(event)
      event && EXPIRY_BY_TOPIC.keys.include?(event['topic'])
    end

    def get_expiry(event)
      EXPIRY_BY_TOPIC[event['topic']]
    end

    def get_uid(event)
      if (campus_solutions_id = event['payload'] && event['payload']['student'] && event['payload']['student']['StudentId'])
        uid = CalnetCrosswalk::ByCsId.new(user_id: campus_solutions_id).lookup_ldap_uid
        logger.error "No UID found for Campus Solutions ID #{campus_solutions_id}" unless uid
      else
        logger.error "Could not parse Campus Solutions ID from event #{event}"
      end
      uid
    end

    def get_instructor_uids(event)
      uids = []
      if (section_data = event['payload'] && event['payload']['student'] && event['payload']['student']['StudentId'].to_s.split('|'))
        if (term_id = section_data[0]) && (section_id = section_data[1])
          instructors = EdoOracle::Queries.get_section_instructors(term_id, section_id)
          instructors.each do |instructor|
            uids.push instructor['ldap_uid'].to_i
          end
          logger.error "No Instructor UIDs found for section #{section_id}, term #{term_id}" unless (uids.length > 0)
        end
      else
        logger.error "Could not parse Instructor UIDs from event #{event}"
      end
      uids
    end

    #TODO Mapping of event topics to expiry modules is incomplete.
    EXPIRY_BY_TOPIC = {
      'sis:staff:advisor' => CampusSolutions::AdvisingExpiry,
      'sis:student:affiliation' => CampusSolutions::UserApiExpiry,
      'sis:student:checklist' => CampusSolutions::ChecklistDataExpiry,
      'sis:student:delegate' => CampusSolutions::DelegateStudentsExpiry,
      'sis:student:deposit' => CampusSolutions::MyDeposit,
      'sis:student:enrollment' => CampusSolutions::EnrollmentTermExpiry,
      'sis:student:eft' => Eft::MyEftEnrollment,
      'sis:student:ferpa' => nil,
      'sis:student:finaid' => CampusSolutions::FinancialAidExpiry,
      'sis:student:financials' => CampusSolutions::MyBilling,
      'sis:student:messages' => MyActivities::Merged,
      'sis:student:serviceindicator' => HubEdos::AcademicStatus,
      'sis:faculty:grade-roster' => CampusSolutions::SectionGradesExpiry
    }
  end
end
