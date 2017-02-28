module Notifications
  class SisExpiryStudentsProvider
    include ClassLogger

    def get_uids(event)
      if event && ids = event.try(:[], 'payload').try(:[], 'students')
        uids = []
        ids.each do |student_id|
          if (uid = CalnetCrosswalk::ByCsId.new(user_id: student_id).lookup_ldap_uid)
            uids << uid
          else
            logger.error "No UID found for Campus Solutions ID #{student_id}"
          end
        end
        uids
      else
        logger.error "Could not parse Campus Solutions ID from event #{event}"
      end
    end
  end
end
