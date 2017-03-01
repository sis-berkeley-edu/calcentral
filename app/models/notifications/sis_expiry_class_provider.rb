module Notifications
  class SisExpiryClassProvider
    include ClassLogger

    def get_uids(event)
      if event && ids = event.try(:[], 'payload').try(:[], 'class').try(:[], 'instructors').try(:[], 'id')
        uids = []
        # 'id' will contain a single value if there is one ID, and an array if there are multiple,
        # so we always wrap it in an array for consistency.
        ids = ([] << ids).flatten
        ids.each do |instructor_id|
          if (uid = CalnetCrosswalk::ByCsId.new(user_id: instructor_id).lookup_ldap_uid)
            uids << uid
          else
            logger.error "No UID found for Campus Solutions ID #{instructor_id}"
          end
        end
        uids
      else
        logger.error "Could not parse Campus Solutions ID from event #{event}"
      end
    end

  end
end
