module CampusSolutions
  class EnrollmentVerificationMessagesController < CampusSolutionsController

    def get
      json_passthrough CampusSolutions::EnrollmentVerificationMessages
    end

  end
end
