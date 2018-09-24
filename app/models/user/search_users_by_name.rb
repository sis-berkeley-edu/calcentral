module User
  class SearchUsersByName

    def search_by(name, opts={})
      return [] if name.blank?
      raise Errors::BadRequestError, 'Wildcard-only searches are not allowed.' if only_special_characters?(name)
      users = search_ldap(name, opts)
      users.each do |user|
        # We negotiate the differences between LDAP and Campus Solutions.
        user[:name] ||= user[:person_name]
        user[:sid] ||= user[:student_id]
        user[:ldapUid] ||= user[:ldap_uid]
      end
      users
    end

    private

    def only_special_characters?(name)
      !!(name =~ /^[\*\?\s]+$/)
    end

    def search_ldap(name, opts)
      users = []
      ldap_users = CalnetLdap::UserAttributes.get_attributes_by_name(name, !!opts[:include_guest_users])
      ldap_users.each do |ldap_user|
        # Allow CalNet attributes to be overridden by other data sources.
        uid = ldap_user[:ldap_uid]
        if (user = User::SearchUsersByUid.new(opts.merge(id: uid)).search_users_by_uid)
          users << user
        end
      end
      users
    end

  end
end
