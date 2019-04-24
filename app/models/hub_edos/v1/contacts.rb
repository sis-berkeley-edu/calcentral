module HubEdos
  module V1
    class Contacts < Student
      include HubEdos::CachedProxy
      include Cache::UserCacheExpiry

      def url
        "#{@settings.base_url}/v1/students/#{@campus_solutions_id}/contacts"
      end

      def json_filename
        'hub_contacts.json'
      end

      def whitelist_fields
        %w(identifiers affiliations names addresses phones emails urls emergencyContacts confidential)
      end

      def build_feed(response)
        remove_invalid_addresses super
      end

      def remove_invalid_addresses(response)
        filtered_addresses = response.try(:[], 'student').try(:[], 'addresses').try(:delete_if) do |address|
          address_is_invalid? address
        end
        response['student']['addresses'] = filtered_addresses unless filtered_addresses.nil?
        response
      end

      def address_is_invalid?(address)
        if (to_date = address.try(:[], 'toDate'))
          to_date = Date.parse(to_date)
          from_date = Date.parse(address.try(:[], 'fromDate'))
          current_date = Settings.terms.fake_now ? Date.parse(Settings.terms.fake_now.to_s) : Date.today
          if (current_date < from_date) || (current_date > to_date)
            return true
          end
        end
        false
      end

    end
  end
end
