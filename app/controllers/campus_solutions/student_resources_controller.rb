module CampusSolutions
  class StudentResourcesController < CampusSolutionsController

    def get
      json_passthrough CampusSolutions::StudentResources, user_id: session['user_id']
    end

  end
end
