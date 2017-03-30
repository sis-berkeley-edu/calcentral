module User
  module Student
    def campus_solutions_id
      @campus_solutions_id ||= lookup_campus_solutions_id
    end

    def lookup_student_id
      return student_id_from_ldap unless Settings.features.allow_legacy_fallback
      student_id_from_ldap || student_id_from_oracle
    end

    def lookup_campus_solutions_id
      CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_campus_solutions_id
    end

    def lookup_delegate_user_id
      CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_delegate_user_id
    end

    def has_legacy_data?(id = nil)
      if (test_id = id || campus_solutions_id || lookup_student_id)
        test_id.to_s.length < 10
      else
        false
      end
    end

    private

    def student_id_from_ldap
      id = (ldap_feed = CalnetLdap::UserAttributes.new(user_id: @uid).get_feed) && ldap_feed[:student_id]
      id if id.present?
    end

    def student_id_from_oracle
      id = (oracle_feed = CampusOracle::UserAttributes.new(user_id: @uid).get_feed) && oracle_feed['student_id']
      id if id.present?
    end

  end
end
