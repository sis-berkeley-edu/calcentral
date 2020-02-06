module User
  class AuthenticationValidator
    extend Cache::Cacheable
    include Cache::UserCacheExpiry
    include Berkeley::UserRoles
    include ClassLogger

    attr_reader :auth_uid

    def initialize(auth_uid, auth_handler=nil)
      @user_auth_handler = auth_handler
      @auth_uid = auth_uid
    end

    def feature_enabled?
      Settings.features.authentication_validator
    end

    def slate_auth_handler
      @slate_auth_handler ||= Settings.slate_auth_handler
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
      cs_feed = HubEdos::PersonApi::V1::SisPerson.new(user_id: @auth_uid).get
      if affiliations = cs_feed.try(:[], :feed).try(:[], 'affiliations')
        affiliations = HashConverter.symbolize affiliations
        cs_roles = roles_from_cs_affiliations(affiliations)
        if @user_auth_handler.present? && is_slate_auth_handler?(@user_auth_handler)
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

    def is_slate_auth_handler?(user_auth_handler)
      user_client = stringify_downcase user_auth_handler[:client]
      user_handler = stringify_downcase user_auth_handler[:handler]
      slate_client = stringify_downcase slate_auth_handler[:client]
      slate_handler = stringify_downcase slate_auth_handler[:handler]
      slate_handler_casv5 = stringify_downcase slate_auth_handler[:handler_casv5]
      user_handler.include?(slate_handler_casv5) || (user_client.include?(slate_client) && user_handler.include?(slate_handler))
    end

    def stringify_downcase(string)
      output = string || ""
      output.to_s.downcase
    end

    def unreleased_applicant?(cs_roles)
      is_applicant = cs_roles.delete(:applicant)
      # Remove preSir since unreleased applicant can be sired or not.
      cs_roles.delete(:preSir)
      !!is_applicant && !cs_roles.has_value?(true)
    end

    def has_ldap_affiliations?
      ldap_attributes = CalnetLdap::UserAttributes.new(user_id: @auth_uid).get_feed
      ldap_roles = ldap_attributes.try(:[], :roles) || {}
      ldap_roles.has_value?(true)
    end

  end
end
