module HubEdos
  module StudentApi
    module V2
      module Student
        # A Student Attribute is a free form characteristic assigned to the student via various processes
        class StudentAttribute

          def initialize(data)
            @data = data
          end

          # a short descriptor representing the kind of attribute assigned to the student, such as American Cultures, Incentive Awards Program, etc.
          def type
            ::HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
          end

          # a short descriptor representing the origination of this attribute
          def reason
            ::HubEdos::Common::Reference::Descriptor.new(@data['reason']) if @data['reason']
          end

          # a component that describes the term on which this attribute became associated with the student
          def from_term
            ::HubEdos::StudentApi::V2::Term::Term.new(@data['fromTerm']) if @data['fromTerm']
          end

          # a component that describes the term on which this attribute is no longer to be associated with the student
          def to_term
            ::HubEdos::StudentApi::V2::Term::Term.new(@data['toTerm']) if @data['toTerm']
          end

          # the date on which this attribute became associated with the student	date
          def from_date
            @from_date ||= begin
              date_string = @data['fromDate']
              Date.parse(date_string) if date_string
            end
          end

          # the date on which this attribute is no longer to be associated with the student	date
          def to_date
            @from_date ||= begin
              date_string = @data['toDate']
              Date.parse(date_string) if date_string
            end
          end

          # free form text giving additional information about this attribute or its assignment
          def comments
            @data['comments']
          end

        end
      end
    end
  end
end
