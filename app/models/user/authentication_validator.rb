module User
  class AuthenticationValidator
    extend Cache::Cacheable
    include Cache::UserCacheExpiry
    include Berkeley::UserRoles
    include ClassLogger

    attr_reader :auth_uid

    def initialize(auth_uid)
      @auth_uid = auth_uid
    end

    def feature_enabled?
      Settings.features.authentication_validator
    end

    def validated_user_id
      if feature_enabled? && cached_held_applicant?
        nil
      else
        @auth_uid
      end
    end

    def cached_held_applicant?
      key = self.class.cache_key @auth_uid
      entry = Rails.cache.read key
      if entry
        logger.debug "Entry is already in cache: #{key}"
        return (entry == NilClass) ? nil : entry
      end
      is_held = held_applicant?
      logger.warn "Held UID #{@auth_uid} will be treated as blank UID" if is_held
      expiration = is_held ? self.class.expires_in('User::AuthenticationValidator::short') : self.class.expires_in
      cached_entry = (is_held.nil?) ? NilClass : is_held
      logger.debug "Cache_key will be #{key}, expiration #{expiration}"
      Rails.cache.write(key,
        cached_entry,
        :expires_in => expiration,
        :force => true)
      is_held
    end

    def held_applicant?
      cs_feed = HubEdos::Affiliations.new(user_id: @auth_uid).get
      if cs_feed.try(:[], :feed) && (student = cs_feed[:feed].try(:[], 'student')) && student.try(:[], 'affiliations')
        cs_feed = HashConverter.symbolize student
        held = unreleased_applicant?(cs_feed[:affiliations])
        has_ldap_affiliations = held ? has_ldap_affiliations? : nil
        is_graduate = held && (!has_ldap_affiliations.nil? && !has_ldap_affiliations) ? is_graduate_applicant? : nil
        held && (!has_ldap_affiliations.nil? && !has_ldap_affiliations) && (!is_graduate.nil? && !is_graduate)
      else
        # We don't know much about this person, but they're not a held applicant.
        false
      end
    end

    def unreleased_applicant?(cs_affiliations)
      roles = roles_from_cs_affiliations(cs_affiliations)
      is_applicant = roles.delete(:applicant)
      !!is_applicant && roles.empty?
    end

    def has_ldap_affiliations?
      ldap_attributes = CalnetLdap::UserAttributes.new(user_id: @auth_uid).get_feed
      ldap_roles = ldap_attributes.try(:[], :roles) || {}
      ldap_roles.has_value?(true)
    end

    def is_graduate_applicant?
      sir_feed = CampusSolutions::Sir::SirStatuses.new(@auth_uid).get_feed
      sir_statuses = sir_feed.try(:[], :sirStatuses) || []
      sir_statuses.any? do |sir_status|
        !sir_status.try(:[], :isUndergraduate)
      end
    end

  end
end
