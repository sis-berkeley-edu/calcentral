module CampusSolutions
  module WorkExperienceUpdatingModel
    def passthrough(model_name, params)
      proxy = model_name.new({user_id: @uid, params: params})
      result = proxy.get
      HubEdos::StudentApi::V1::WorkExperience.expire @uid
      result
    end
  end
end
