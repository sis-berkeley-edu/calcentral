module HubEdos
  module StudentApi
    module V2
      module Student
        class AcademicStatuses
          attr_reader :user

          def initialize(user)
            @user = user
          end

          def all
            @all ||= data.collect do |academic_status_data|
              ::HubEdos::StudentApi::V2::Student::AcademicStatus.new(academic_status_data)
            end
          end

          private

          def data
            api_response = ::HubEdos::StudentApi::V2::Feeds::AcademicStatuses.new(user_id: @user.uid).get_inactive_completed
            if api_response[:statusCode] == 200
              return api_response.try(:[], :feed).try(:[], 'academicStatuses') || []
            end
            []
          end
        end
      end
    end
  end
end
