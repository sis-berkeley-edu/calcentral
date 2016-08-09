module CampusSolutions
  class EnrollmentVerificationDeeplinkController < CampusSolutionsController
    include DisallowAdvisorViewAs
    include DisallowClassicViewAs

    def get
      json_passthrough CampusSolutions::EnrollmentVerificationDeeplink
    end

  end
end
