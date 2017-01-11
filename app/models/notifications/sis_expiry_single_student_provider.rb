module Notifications
  class SisExpirySingleStudentProvider
    include ClassLogger

    # This class is deprecated.  Eventually all event message payloads will be restructured to return a list of IDs, and
    # SisExpiryStudentProvider will be phased out in favor of SisExpiryStudentsProvider.

    def get_uids(event)
      if (campus_solutions_id = event.try(:[], 'payload').try(:[], 'student').try(:[], 'StudentId'))
        uid = CalnetCrosswalk::ByCsId.new(user_id: campus_solutions_id).lookup_ldap_uid
        logger.error "No UID found for Campus Solutions ID #{campus_solutions_id}" unless uid
      else
        logger.error "Could not parse Campus Solutions ID from event #{event}"
      end
      uid
    end
  end
end
