module CampusSolutions
  module Sir
    class MySirResponse < UserSpecificModel

      include CampusSolutions::PersonDataUpdatingModel

      def update(params = {})
        CampusSolutions::ChecklistDataExpiry.expire @uid
        passthrough(CampusSolutions::Sir::SirResponse, params)
      end

    end
  end
end
