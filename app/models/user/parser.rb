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
      identifiers(ldap_record).merge({
        email_address: string_attribute(ldap_record, :mail) || string_attribute(ldap_record, :berkeleyeduofficialemail),
        first_name: string_attribute(ldap_record, :berkeleyEduFirstName) || string_attribute(ldap_record, :givenname),
        last_name: string_attribute(ldap_record, :berkeleyEduLastName) || string_attribute(ldap_record, :sn),
        person_name: string_attribute(ldap_record, :displayname),
        roles: roles,
        official_bmail_address: string_attribute(ldap_record, :berkeleyeduofficialemail)
      })
    end

    def identifiers(ldap_record)
      sid = string_attribute(ldap_record, :berkeleyedustuid)
      cs_id = string_attribute(ldap_record, :berkeleyeducsid)
      ldap_uid = string_attribute(ldap_record, :uid)
      if sid.present? && cs_id.present? && sid != cs_id
        logger.warn "Conflicting berkeleyEduStuID #{sid} and berkeleyEduCSID #{cs_id} for UID #{ldap_uid}"
      end
      {
        ldap_uid: ldap_uid,
        student_id: sid,
        campus_solution_id: cs_id
      }
    end

    def string_attribute(ldap_record, key)
      if (attribute = ldap_record[key].try(:first).try(:to_s))
        safe_utf8 attribute
      end
    end

    def has_role(user, roles)
      roles.blank? || roles.find { |role| user[:roles][role] }
    end

  end
end
