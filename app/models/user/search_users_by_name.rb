module User
  class SearchUsersByName
    def search_by(name, opts = {})
      return [] if name.blank?
      raise Errors::BadRequestError, "Wildcard-only searches are not allowed." if only_special_characters?(name)
      search_sisedo(name, opts)
    end

    private

    def only_special_characters?(name)
      !!(name =~ /^[\*\?\s]+$/)
    end

    def search_sisedo(name, opts)
      users = []
      search_string = name.to_s.gsub(/[^0-9a-z ]/i, '')
      sisedo_users = EdoOracle::Queries.search_students(name)
      sisedo_users.each do |sisedo_user|
        if uid = get_ldap_uid(sisedo_user)
          if (user = User::SearchUsersByUid.new(opts.merge(id: uid)).search_users_by_uid)
            sisedo_user[:sid] ||= user[:campusSolutionsId]
            sisedo_user[:roles] ||= user[:roles]
            sisedo_user[:ldapUid] ||= user[:ldapUid]
            users << HashConverter.camelize(sisedo_user)
          end
        end
      end
      users
    end

    def get_ldap_uid(sisedo_user)
      campus_uid = sisedo_user.try(:[], 'campus_uid').to_s.strip.presence
      oprid = sisedo_user.try(:[], 'oprid').to_s.strip.presence
      student_id = sisedo_user.try(:[], 'student_id')
      campus_uid || oprid || User::Identifiers.lookup_ldap_uid(student_id)
    end
  end
end
