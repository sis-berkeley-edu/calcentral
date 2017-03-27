module Notifications
  class SisExpiryStudentsProvider
    include ClassLogger

    # This class will handle anything wrapped in a <STUDENTS /> tag - this could be a single item or an array.
    #
    # Single item example:
    #   "students": {"id": 123}
    #
    # Array example:
    #  "students": {"id": [123, 456]}

    def get_uids(event)
      if event && (ids = event.try(:[], 'payload').try(:[], 'students').try(:[], 'id'))
        uids = []
        Array(ids).each do |student_id|
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
