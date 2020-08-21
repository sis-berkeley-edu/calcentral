module HubEdos
  module StudentApi
    module V2
      module Student
        class StudentAttributes
          attr_reader :user

          def initialize(user)
            @user = user
          end

          def all
            @all ||= data.collect do |student_attribute_data|
              ::HubEdos::StudentApi::V2::Student::StudentAttribute.new(student_attribute_data)
            end
          end

          def find_all_by_type_code(code)
            all.select {|sa| sa.type_code == code}
          end

          private

          def data
            api_response = ::HubEdos::StudentApi::V2::Feeds::StudentAttributes.new(user_id: @user.uid).get
            if api_response[:statusCode] == 200
              return api_response.try(:[], :feed).try(:[], 'studentAttributes') || []
            end
            []
          end
        end
      end
    end
  end
end
