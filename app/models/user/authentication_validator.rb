module User
  class AuthenticationValidator
    extend Cache::Cacheable
    include Cache::UserCacheExpiry
    include Berkeley::UserRoles
    include ClassLogger

    attr_reader :auth_uid

    def initialize(auth_uid, auth_handler=nil)
      @auth_handler = auth_handler
      @auth_uid = auth_uid
    end

    def feature_enabled?
      Settings.features.authentication_validator
    end

    def slate_auth_handler
      @slate_handler ||= Settings.authentication_handlers.slate.to_s.downcase
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
      cs_student = cs_feed.try(:[], :feed).try(:[], 'student')
      if affiliations = cs_student.try(:[], 'affiliations')
        affiliations = HashConverter.symbolize affiliations
        cs_roles = roles_from_cs_affiliations(affiliations)
        user_auth_handler = @auth_handler.to_s.downcase
        if user_auth_handler.include?(slate_auth_handler)
          return !cs_roles[:releasedAdmit]
        else
          unreleased = unreleased_applicant?(cs_roles)
          has_ldap_affiliations = unreleased ? has_ldap_affiliations? : nil
          return unreleased && (!has_ldap_affiliations.nil? && !has_ldap_affiliations)
        end
      else
        # We don't know much about this person, but they're not a held applicant.
        false
      end
    end

    def unreleased_applicant?(cs_roles)
      is_applicant = cs_roles.delete(:applicant)
      !!is_applicant && !cs_roles.has_value?(true)
    end

    def has_ldap_affiliations?
      ldap_attributes = CalnetLdap::UserAttributes.new(user_id: @auth_uid).get_feed
      ldap_roles = ldap_attributes.try(:[], :roles) || {}
      ldap_roles.has_value?(true)
    end

  end
end
