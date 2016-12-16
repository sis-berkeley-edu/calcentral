module CalnetCrosswalk
  class Proxy < BaseProxy

    include ClassLogger
    include Proxies::Mockable
    include Proxies::Tls12

    APP_ID = 'calnetcrosswalk'
    APP_NAME = 'Calnet Crosswalk'

    def self.id_type
      self.name.demodulize.sub(/\ABy/,'').upcase
    end

    def initialize(options = {})
      super(Settings.calnet_crosswalk_proxy, options)
      initialize_mocks if @fake
    end

    def instance_key
      @uid
    end

    def json_filename
      "calnet_crosswalk_#{@uid}.json"
    end

    def mock_json
      json = read_file('fixtures', 'json', json_filename)
      if json.blank?
        # fall back to an EMPLID that we know is in CS
        json = read_file('fixtures', 'json', 'calnet_crosswalk_12345.json')
      end
      json
    end

    def get
      if @uid.blank? && !@fake
        logger.error "Crosswalk called with empty #{self.class.id_type}!"
        return {
          errored: true
        }
      end
      internal_response = self.class.smart_fetch_from_cache(id: instance_key) do
        get_internal
      end
      if internal_response[:notFound] || internal_response[:statusCode] < 400
        internal_response
      else
        logger.error "Got Crosswalk error for #{self.class.id_type} #{@uid} with response #{internal_response}"
        {
          errored: true
        }
      end
    end

    def get_internal
      logger.info "Fake = #{@fake}; Making request to #{url} on behalf of #{self.class.id_type} #{@uid}; cache expiration #{self.class.expires_in}"
      response = get_response(url, request_options)
      logger.debug "Remote server status #{response.code}, Body = #{response.body}"
      internal_response = {
        statusCode: response.code,
        feed: response.parsed_response
      }
      if response.code == 404 && response.parsed_response.nil?
        logger.info "Requested #{self.class.id_type} #{@uid} not found in Crosswalk"
        internal_response[:notFound] = true
      end
      internal_response
    end

    def request_options(opts = {})
      super(opts).merge({
        digest_auth: {username: @settings.username, password: @settings.password},
        on_error: {rescue_status: 404}
      })
    end

    def lookup_campus_solutions_id
      lookup_id 'CAMPUS_SOLUTIONS_ID'
    end

    def cache_campus_solutions_id(value)
      cache_id('CAMPUS_SOLUTIONS_ID', value)
    end

    def lookup_legacy_student_id
      lookup_id 'LEGACY_SIS_STUDENT_ID'
    end

    def cache_legacy_student_id(value)
      cache_id('LEGACY_SIS_STUDENT_ID', value)
    end

    def lookup_delegate_user_id
      lookup_id 'DELEGATE_USER_ID'
    end

    def cache_delegate_user_id(value)
      cache_id('DELEGATE_USER_ID', value)
    end

    def lookup_id(id_type)
      self.class.smart_fetch_from_cache({id: "#{@uid}/#{id_type}"}) do
        id = nil
        response = get
        if response[:errored] || response[:notFound]
          return nil
        end
        feed = response[:feed]
        if feed.present?
          feed['Person']['identifiers'].each do |identifier|
            # Conservative check on isPrimaryForIdentifierType: evaluate to false if and only if element is present and equal to false.
            if (identifier['identifierTypeName'] == id_type) && !(identifier['isPrimaryForIdentifierType'].to_s =~ /false/i)
              id = identifier['identifierValue']
              break
            end
          end
        end
        id
      end
    end

    def lookup_ldap_uid
      self.class.smart_fetch_from_cache({id: "#{@uid}/CALNET_UID"}) do
        id = nil
        response = get
        if response[:errored] || response[:notFound]
          return nil
        end
        feed = response[:feed]
        if feed.present?
          id = feed['Person']['uid']
        end
        id
      end
    end

    def cache_id(id_type, id_value)
      self.class.fetch_from_cache("#{@uid}/#{id_type}", true) do
        id_value
      end
    end

    def self.expire(uid=nil)
      super(uid)
      ['CAMPUS_SOLUTIONS_ID', 'LEGACY_SIS_STUDENT_ID', 'DELEGATE_USER_ID'].each do |id_type|
        key = cache_key "#{uid}/#{id_type}"
        Rails.cache.delete key
        Rails.logger.debug "Expired cache_key #{key}"
      end
    end

  end
end
