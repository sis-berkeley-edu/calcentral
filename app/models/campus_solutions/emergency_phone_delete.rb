module CampusSolutions
  class EmergencyPhoneDelete < DeletingProxy

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
          FieldMapping.required(:phoneType, :PHONE_TYPE)
        ]
      )
    end

    def xml_filename
      'emergency_phone_delete.xml'
    end

    def response_root_xml_node
      'EMERGENCY_PHONE_DELETE_RESPONSE'
    end

    def url
      "#{@settings.base_url}/UC_CC_EMER_PHONE.v1/emerphone/delete"
    end

  end
end
