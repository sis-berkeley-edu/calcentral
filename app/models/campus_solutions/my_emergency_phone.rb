module CampusSolutions
  class MyEmergencyPhone < UserSpecificModel

    include EmergencyContactsUpdatingModel

    def update(params = {})
      passthrough(CampusSolutions::EmergencyPhone, params)
    end

    def delete(params = {})
      passthrough(CampusSolutions::EmergencyPhoneDelete, params)
    end

  end
end
