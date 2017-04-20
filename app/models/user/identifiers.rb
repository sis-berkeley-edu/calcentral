module User
  module Identifiers
    def lookup_campus_solutions_id(uid = nil)
      User::Identifiers.lookup_campus_solutions_id(uid || @uid)
    end

    def has_legacy_student_data?(id = nil)
      User::Identifiers.has_legacy_student_data?(id || lookup_campus_solutions_id)
    end

    def self.cache(ldap_uid, campus_solutions_id)
      Cached.write_cache(ldap_uid, uid_key(campus_solutions_id))
      Cached.write_cache(campus_solutions_id, cs_id_key(ldap_uid))
    end

    def self.lookup_campus_solutions_id(ldap_uid)
      cs_id = Cached.fetch_from_cache cs_id_key(ldap_uid)
      if cs_id.blank?
        if Settings.calnet_crosswalk_proxy.enabled
          cs_id = CalnetCrosswalk::ByUid.new(user_id: ldap_uid).lookup_campus_solutions_id
        else
          cs_id = (ldap_feed = CalnetLdap::UserAttributes.new(user_id: ldap_uid).get_feed) && ldap_feed[:campus_solutions_id]
        end
        cache(ldap_uid, cs_id)
      end
      cs_id
    end

    def self.lookup_ldap_uid(cs_id)
      ldap_uid = Cached.fetch_from_cache uid_key(cs_id)
      if ldap_uid.blank?
        if Settings.calnet_crosswalk_proxy.enabled
          ldap_uid = CalnetCrosswalk::ByCsId.new(user_id: cs_id).lookup_ldap_uid
        else
          ldap_uid = (ldap_feed = CalnetLdap::UserAttributes.get_feed_by_cs_id cs_id) && ldap_feed[:ldap_uid]
        end
        cache(ldap_uid, cs_id)
      end
      ldap_uid
    end

    def self.has_legacy_student_data?(student_id)
      student_id.present? && student_id.to_s.length < 10
    end

    def self.cs_id_key(ldap_uid)
      "#{ldap_uid}/CAMPUS_SOLUTIONS_ID"
    end

    def self.uid_key(campus_solutions_id)
      "#{campus_solutions_id}/CALNET_UID"
    end

    class Cached
      extend Cache::Cacheable
      include Cache::UserCacheExpiry

      def self.expire(uid=nil)
        key = cache_key User::Identifiers.cs_id_key(uid)
        Rails.cache.delete key
        Rails.logger.debug "Expired cache_key #{key}"
      end
    end

  end
end
