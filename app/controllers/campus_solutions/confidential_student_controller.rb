module CampusSolutions
  class ConfidentialStudentController < CampusSolutionsController

    def get_message
      json_passthrough CampusSolutions::ConfidentialStudentMessage
    end

  end
end
