module CampusSolutions
  class EmergencyPhone < PostingProxy

    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:contactName, :CONTACT_NAME),
          FieldMapping.required(:phone, :PHONE),
          FieldMapping.required(:phoneType, :PHONE_TYPE),
          FieldMapping.required(:extension, :EXTENSION),
          FieldMapping.required(:countryCode, :COUNTRY_CODE)
        ]
      )
    end

    def request_root_xml_node
      'UC_EMER_PHONE'
    end

    def error_response_root_xml_node
      'UC_FA_T_C_FAULT'
    end

    def xml_filename
      'emergency_phone_post.xml'
    end

    def url
      "#{@settings.base_url}/UC_CC_EMER_PHONE.v1/emerphone/post/"
    end
  end
end
