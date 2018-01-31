module CampusSolutions
  module PersonDataUpdatingModel
    def passthrough(model_name, params)
      proxy = model_name.new({user_id: @uid, params: params})
      result = proxy.post
      PersonDataExpiry.expire @uid
      result
    end
  end
end
