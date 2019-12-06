module CampusSolutions
  class WorkExperienceController < CampusSolutionsController

    before_action :exclude_acting_as_users

    def post
      post_passthrough CampusSolutions::MyWorkExperience
    end

    def delete
      delete_passthrough CampusSolutions::MyWorkExperience
    end

  end
end
