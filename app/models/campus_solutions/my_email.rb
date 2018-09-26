module CampusSolutions
  class MyEmail < UserSpecificModel

    include UserApiUpdatingModel

    def update(params = {})
      passthrough(CampusSolutions::Email, params)
    end

    def delete(params = {})
      passthrough(CampusSolutions::EmailDelete, params)
    end

  end
end
