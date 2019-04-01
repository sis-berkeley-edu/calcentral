module User
  module BasicAttributes
    extend self

    def attributes_for_uids(uids)
      return [] if uids.blank?
      uid_set = uids.to_set
      attrs = []
      # Oracle dislikes ' IN ()' queries with more than 1000 items.
      uids.each_slice(1000) do |next_batch|
        rows = EdoOracle::Queries.get_basic_people_attributes(next_batch)
        rows.each do |result|
          uid_set.delete result['ldap_uid']
          attrs << transform_campus_row(result)
        end
      end
      attrs.concat CalnetLdap::UserAttributes.get_bulk_attributes(uid_set) if uid_set.any?
      attrs
    end

    def transform_campus_row(result)
      {
        email_address: result['email_address'],
        first_name: result['first_name'],
        last_name: result['last_name'],
        ldap_uid: result['ldap_uid'],
        roles: Berkeley::UserRoles.roles_from_campus_row(result),
        student_id: result['student_id']
      }
    end
  end
end
