module HubEdos
  module StudentApi
    module V2
      module Feeds
        class Contacts < ::HubEdos::StudentApi::V2::Feeds::Proxy
          include HubEdos::CachedProxy
          include Cache::UserCacheExpiry

          def url
            "#{@settings.base_url}/v2/students/#{@campus_solutions_id}?inc-cntc=true"
          end

          def json_filename
            'hub_v2_student_contact.json'
          end

          def build_feed(response)
            feed = super(response)
            transform_address_keys(feed)
          end

          def transform_address_keys(student_hash)
            if student_hash['addresses'].present?
              student_hash['addresses'].each do |address|
                address['state'] = address.delete('stateCode')
                address['postal'] = address.delete('postalCode')
                address['country'] = address.delete('countryCode')
              end
            end
            student_hash
          end

          def whitelist_fields
            ['addresses', 'phones', 'emails', 'emergencyContacts']
          end
        end
      end
    end
  end
end
