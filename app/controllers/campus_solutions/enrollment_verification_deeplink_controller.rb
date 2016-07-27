module CampusSolutions
  class EnrollmentVerificationDeeplinkController < CampusSolutionsController

    def get
      json_passthrough CampusSolutions::EnrollmentVerificationDeeplink
    end

  end
end
