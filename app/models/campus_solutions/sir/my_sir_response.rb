module CampusSolutions
  module Sir
    class MySirResponse < UserSpecificModel

      include CampusSolutions::ChecklistDataUpdatingModel

      def update(params = {})
        passthrough(CampusSolutions::Sir::SirResponse, params)
      end

    end
  end
end
