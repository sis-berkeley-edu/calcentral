module User
  module Identifiers
    def lookup_student_id
      if !(sid = student_id_from_ldap) && Settings.features.allow_legacy_fallback
        sid = student_id_from_oracle
      end
      sid
    end

    def lookup_campus_solutions_id
      if Settings.calnet_crosswalk_proxy.enabled
        CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_campus_solutions_id
      else
        csid = (ldap_feed = CalnetLdap::UserAttributes.new(user_id: @uid).get_feed) && ldap_feed[:campus_solutions_id]
        csid if csid.present?
      end
    end

    def lookup_delegate_user_id
      if Settings.calnet_crosswalk_proxy.enabled
        CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_delegate_user_id
      else
        nil
      end
    end

    def has_legacy_data?(id = nil)
      if (test_id = id || lookup_campus_solutions_id || lookup_student_id)
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
