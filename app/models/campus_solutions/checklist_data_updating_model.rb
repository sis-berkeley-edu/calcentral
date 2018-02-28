module CampusSolutions
  module ChecklistDataUpdatingModel
    def passthrough(model_name, params)
      proxy = model_name.new({user_id: @uid, params: params})
      result = proxy.post
      ChecklistDataExpiry.expire @uid
      result
    end
  end
end
