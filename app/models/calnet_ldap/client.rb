require 'net/ldap'

module CalnetLdap
  class Client
    include User::Parser
    include ClassLogger

    PEOPLE_DN = 'ou=people,dc=berkeley,dc=edu'
    GUEST_DN = 'ou=guests,dc=berkeley,dc=edu'
    TIMESTAMP_FORMAT = '%Y%m%d%H%M%SZ'

    # TODO Ask CalNet for suggested maximum number of search values.
    BATCH_QUERY_MAXIMUM = 20

    # String based searches must be limited to avoid looping over thousands of results.
    NAME_SEARCH_SIZE_LIMIT = '30'

    def initialize
      @ldap = Net::LDAP.new({
        host: Settings.ldap.host,
        port: Settings.ldap.port,
        encryption: { method: :simple_tls },
        auth: {
          method: :simple,
          username: Settings.ldap.application_bind,
          password: Settings.ldap.application_password
        }
      })
    end

    def guests_modified_since(timestamp)
      ldap_timestamp = timestamp.to_time.utc.strftime(TIMESTAMP_FORMAT)
      modified_timestamp_filter = Net::LDAP::Filter.ge('modifytimestamp', ldap_timestamp)
      search(base: GUEST_DN, filter: modified_timestamp_filter)
    end

    def search_by_name(name, include_guest_users=false)
      return [] if (tokens = tokenize_for_search_by_name name).empty?
      if tokens.length == 1
        filter = Net::LDAP::Filter.intersect(
          Net::LDAP::Filter.eq('sn', "#{tokens[0]}*"),
          Net::LDAP::Filter.eq('givenname', "#{tokens[0]}*"))
        search_by_filter filter, include_guest_users
      else
        parent_filter = nil
        tokens.permutation.to_a.each do |args|
          filter = Net::LDAP::Filter.eq 'displayname', "#{args.join '* '}*"
          parent_filter = parent_filter.nil? ? filter : Net::LDAP::Filter.intersect(parent_filter, filter)
        end
        search_by_filter parent_filter, include_guest_users
      end
    end

    def search_by_filter(filter, include_guest_users=false)
      results = []
      results.concat search(base: PEOPLE_DN, filter: filter, size: NAME_SEARCH_SIZE_LIMIT)
      results.concat search(base: GUEST_DN, filter: filter, size: NAME_SEARCH_SIZE_LIMIT) if include_guest_users
      results
    end

    def search_by_uid(uid)
      filter = uids_filter([uid])
      results = search(base: PEOPLE_DN, filter: filter)
      if results.empty?
        results = search(base: GUEST_DN, filter: filter)
      end
      results.first
    end

    def search_by_uids(uids)
      [].tap do |results|
        uids.each_slice(BATCH_QUERY_MAXIMUM).map do |uid_slice|
          people_results = search(base: PEOPLE_DN, filter: uids_filter(uid_slice))
          results.concat people_results
          if people_results.length != uid_slice.length
            remaining_uids = uid_slice - people_results.collect { |entry| entry[:uid].first }
            guest_results = search(base: GUEST_DN, filter: uids_filter(remaining_uids))
            results.concat guest_results
          end
        end
      end
    end

    private

    def uids_filter(uids)
      uids.map { |uid| Net::LDAP::Filter.eq('uid', uid.to_s) }.inject :|
    end

    def search(args = {})
      ActiveSupport::Notifications.instrument('proxy', {class: self.class, search: args}) do
        response = @ldap.search args
        if response.nil?
          logger.error "LDAP search with args #{args} returned: #{@ldap.get_operation_result}"
          []
        else
          logger.debug "LDAP search with args #{args} returned: #{response}"
          response
        end
      end
    end

  end
end
