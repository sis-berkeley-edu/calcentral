module CampusSolutions
  module EmergencyContactsUpdatingModel
    def passthrough(model_name, params)
      proxy = model_name.new({user_id: @uid, params: params})
      result = proxy.get
      PersonDataExpiry.expire @uid
      EmergencyContacts.expire @uid
      result
    end
  end
end
