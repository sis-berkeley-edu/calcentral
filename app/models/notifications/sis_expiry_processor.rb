module Notifications
  class SisExpiryProcessor
    include ClassLogger

    PROVIDERS = Hash[
      'class' => SisExpiryClassProvider.new,
      'student' => SisExpirySingleStudentProvider.new,
      'students' => SisExpiryStudentsProvider.new
    ]

    def process(event, timestamp)
      return false unless accept? event
      logger.debug "Processing event: #{event}; timestamp = #{timestamp}"
      if (expiry_module = get_expiry event)
        payload = event.try(:[], 'payload')
        payload.keys.each do |key|
          uids = PROVIDERS[key].get_uids(event)
          expiry_module.expire uids if uids
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

    #TODO Mapping of event topics to expiry modules is incomplete.
    EXPIRY_BY_TOPIC = {
      'sis:staff:advisor' => CampusSolutions::AdvisingExpiry,
      'sis:student:academic-progress-report' => CampusSolutions::DegreeProgress::UndergradRequirementsExpiry,
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
      'sis:student:serviceindicator' => HubEdos::MyAcademicStatus,
      'sis:class:grade-roster' => CampusSolutions::SectionGradesExpiry
    }
  end
end
