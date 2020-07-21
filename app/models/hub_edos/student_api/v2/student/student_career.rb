module HubEdos
  module StudentApi
    module V2
      module Student
        # A Student Career describes a high level grouping of academic policy, such as "Undergraduate" or "Law," the student is pursuing
        class StudentCareer
          def initialize(data)
            @data = data || {}
          end

          # a short descriptor representing the highest level grouping of academic policy within UC Berkeley
          # Examples include "Undergraduate," "Graduate," and "Law."
          def academic_career
            ::HubEdos::Common::Reference::Descriptor.new(@data['academicCareer']) if @data['academicCareer']
          end

          # a component representing when the student became eligible to enroll within the career
          def matriculation
            ::HubEdos::StudentApi::V2::StudentRecord::Matriculation.new(@data['matriculation'])
          end

          # the date on which the career was associated with the student
          def from_date
            @from_date ||= begin
              date_string = @data['fromDate']
              Date.parse(date_string) if date_string
            end
          end

          # the date on which the career was no longer associated with the student
          def to_date
            @to_date ||= begin
              date_string = @data['toDate']
              Date.parse(date_string) if date_string
            end
          end

        end
      end
    end
  end
end
