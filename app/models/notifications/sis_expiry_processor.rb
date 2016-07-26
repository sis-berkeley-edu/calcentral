module Notifications
  class SisExpiryProcessor
    include ClassLogger

    def process(event, timestamp)
      return false unless accept? event
      logger.debug "Processing event: #{event}; timestamp = #{timestamp}"
      if (expiry_module = get_expiry event) && (uid = get_uid event)
        expiry_module.expire uid
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

    #TODO Mapping of event topics to expiry modules is incomplete.
    EXPIRY_BY_TOPIC = {
      'sis:staff:advisor' => CampusSolutions::AdvisingResources,
      'sis:student:affiliation' => CampusSolutions::UserApiExpiry,
      'sis:student:checklist' => CampusSolutions::ChecklistDataExpiry,
      'sis:student:delegate' => CampusSolutions::DelegateStudentsExpiry,
      'sis:student:deposit' => CampusSolutions::MyDeposit,
      'sis:student:enrollment' => CampusSolutions::EnrollmentTermExpiry,
      'sis:student:ferpa' => nil,
      'sis:student:finaid' => CampusSolutions::FinancialAidExpiry,
      'sis:student:financials' => CampusSolutions::MyBilling,
      'sis:student:messages' => MyActivities::Merged,
      'sis:student:serviceindicator' => HubEdos::MyAcademicStatus
    }
  end
end
