module HubEdos
  module StudentApi
    module V2
      module Student
        def academic_statuses(user)
          @academic_statuses ||= ::HubEdo::StudentApi::V2::Student::AcademicStatuses.new(user)
        end

        def attributes(user)
          @attributes ||= ::HubEdos::StudentApi::V2::Student::StudentAttributes.new(user)
        end
      end
    end
  end
end
