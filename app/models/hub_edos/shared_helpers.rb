module HubEdos
  # Helper methods shared between V1 and V2 proxies
  module SharedHelpers
    def self.filter_fields(input_hash, whitelisted_fields = nil)
      return input_hash if whitelisted_fields.blank?
      input_hash.slice(*whitelisted_fields)
    end

    def self.transform_address_keys(student_hash)
      if student_hash['addresses'].present?
        student_hash['addresses'].each do |address|
          address['state'] = address.delete('stateCode')
          address['postal'] = address.delete('postalCode')
          address['country'] = address.delete('countryCode')
        end
      end
      student_hash
    end
  end
end
