module User
  module Parser
    include SafeUtf8Encoding

    def parse_all(ldap_records)
      ldap_records.map { |ldap_record| parse ldap_record }
    end

    def parse(ldap_record)
      affiliation_roles = Berkeley::UserRoles.roles_from_ldap_affiliations ldap_record
      group_roles = Berkeley::UserRoles.roles_from_ldap_groups(ldap_record[:berkeleyeduismemberof])
      roles = group_roles.merge affiliation_roles
      roles[:confidential] = true if string_attribute(ldap_record, :berkeleyeduconfidentialflag) == 'true'
      {
        email_address: string_attribute(ldap_record, :mail) || string_attribute(ldap_record, :berkeleyeduofficialemail),
        first_name: string_attribute(ldap_record, :berkeleyEduFirstName) || string_attribute(ldap_record, :givenname),
        last_name: string_attribute(ldap_record, :berkeleyEduLastName) || string_attribute(ldap_record, :sn),
        ldap_uid: string_attribute(ldap_record, :uid),
        person_name: string_attribute(ldap_record, :displayname),
        roles: roles,
        student_id: string_attribute(ldap_record, :berkeleyedustuid),
        official_bmail_address: string_attribute(ldap_record, :berkeleyeduofficialemail),
        campus_solutions_id: string_attribute(ldap_record, :berkeleyeducsid)
      }
    end

    def string_attribute(ldap_record, key)
      if (attribute = ldap_record[key].try(:first).try(:to_s))
        safe_utf8 attribute
      end
    end

    def tokenize_for_search_by_name(phrase)
      return [] if phrase.blank?
      tokens = phrase.strip.gsub(/[;,\s]+/, ' ').split /[\s,]/
      # Discard middle initials, generational designations (e.g., Jr.) and academic suffixes (e.g., M.A.)
      tokens.select { |token| !token.end_with? '.' }
    end

    def has_role(user, roles)
      roles.blank? || roles.find { |role| user[:roles][role] }
    end

  end
end
