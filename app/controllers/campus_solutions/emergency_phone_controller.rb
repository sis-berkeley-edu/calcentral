module CampusSolutions
  class EmergencyPhoneController < CampusSolutionsController

    before_filter :exclude_acting_as_users

    def post
      post_passthrough CampusSolutions::MyEmergencyPhone
    end

    def delete
      delete_passthrough CampusSolutions::MyEmergencyPhone
    end

  end
end
