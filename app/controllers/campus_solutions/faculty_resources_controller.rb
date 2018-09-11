module CampusSolutions
  class FacultyResourcesController < CampusSolutionsController

    def get
      json_passthrough CampusSolutions::FacultyResources, user_id: session['user_id']
    end

  end
end
