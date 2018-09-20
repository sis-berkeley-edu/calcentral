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
        if uid = sisedo_user['campus_uid']
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
  end
end
