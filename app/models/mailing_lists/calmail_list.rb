module MailingLists
  class CalmailList < SiteMailingList

    # Lists with membership stored in Calmail enter a 'pending' state on first save, and are not
    # considered 'created' until we've verified creation on the Calmail side.
    before_create { self.state = 'pending' }
    after_find { check_for_creation if self.state == 'pending' }

    def self.domain
      Settings.calmail_proxy.domain
    end

    private

    def add_list_urls(feed)
      feed[:mailingList][:creationUrl] = build_creation_url if self.state == 'pending'
      feed[:mailingList][:administrationUrl] = build_administration_url if self.state == 'created'
    end

    def build_administration_url
      Settings.calmail_proxy.base_url.sub(
        /api1\Z/,
        "list/listinfo/#{self.list_name}%40#{self.class.domain}"
      )
    end

    def build_creation_url
      params = {
        domain_name: self.class.domain,
        listname: self.list_name,
        owner_address: Settings.calmail_proxy.owner_address,
        advertised: 0,
        subscribe_policy: 3,
        moderate: 1,
        generic_nonmember_action: 1
      }
      Settings.calmail_proxy.base_url.sub(/api1\Z/, "list/domain_create_list2?#{params.to_query}")
    end

    def check_for_creation
      if name_available? == false
        self.state = 'created'
        save
      end
    end

    def add_member(address, first_name, last_name, roles)
      @add_member_proxy ||= Calmail::AddListMember.new
      proxy_response = @add_member_proxy.add_member(self.list_name, address, "#{first_name} #{last_name}")
      proxy_response[:response] && proxy_response[:response][:added]
    end

    def get_list_members
      if (list_members = Calmail::ListMembers.new.list_members self.list_name)
        addresses = list_members[:response] && list_members[:response][:addresses]
        # Addresses are returned in a Hash for 1) quick lookup; 2) compatibility with non-Calmail implementations that
        # return additional member data.
        addresses.inject({}) { |hash, address| hash[address] = true; hash }
      end
    end

    def log_population_results
      # The Calmail API may successfully update memberships without returning a success response, so do
      # a post-update check on any failures to see if they were real failures.
      if any_population_failures? && (addresses_after_update = get_list_members)
        population_results[:add][:failure].reject! { |address| addresses_after_update.has_key? address }
        population_results[:remove][:failure].reject! { |address| !addresses_after_update.has_key? address }
        population_results[:add][:success] = population_results[:add][:total] - population_results[:add][:failure].count
        population_results[:remove][:success] = population_results[:remove][:total] - population_results[:remove][:failure].count
        self.members_count = addresses_after_update.count
      else
        self.members_count = population_results[:initial_count] + population_results[:add][:success] - population_results[:remove][:success]
      end

      logger.info "Added #{population_results[:add][:success]} of #{population_results[:add][:total]} new site members."
      if population_results[:add][:failure].any?
        logger.error "Failed to add #{population_results[:add][:failure].count} addresses to #{self.list_name}: #{population_results[:add][:failure].join ', '}"
      end

      logger.info "Removed #{population_results[:remove][:success]} of #{population_results[:remove][:total]} former site members."
      if population_results[:remove][:failure].any?
        logger.error "Failed to remove #{population_results[:remove][:failure].count} addresses from #{self.list_name}: #{population_results[:remove][:failure].join ', '}"
      end
    end

    def name_available?
      return if list_name.blank?
      if (check_namespace = Calmail::CheckNamespace.new.name_available? self.list_name) &&
        (check_namespace[:response] == true || check_namespace[:response] == false)
        check_namespace[:response]
      else
        self.request_failure = 'There was an error connecting to Calmail.'
        nil
      end
    end

    def remove_member(address)
      @remove_member_proxy ||= Calmail::RemoveListMember.new
      proxy_response = @remove_member_proxy.remove_member(self.list_name, address)
      proxy_response[:response] && proxy_response[:response][:removed]
    end

    def update_required?(old_member_data, new_member_data)
      # The Calmail implementation does not support member data updates.
      false
    end

  end
end
