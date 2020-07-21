module HubEdos
  module StudentApi
    module V2
      module Student
        # A Student Attribute is a free form characteristic assigned to the student via various processes.
        class StudentAttribute

          def initialize(data)
            @data = data || {}
          end

          # a short descriptor representing the kind of attribute assigned to the student, such as American Cultures, Incentive Awards Program, etc.
          def type
            ::HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
          end

          # returns type descriptor code
          def type_code
            type.try(:code)
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
              Date.parse(@data['fromDate']) if @data['fromDate']
            end
          end

          # the date on which this attribute is no longer to be associated with the student	date
          def to_date
            @to_date ||= begin
              Date.parse(@data['toDate']) if @data['toDate']
            end
          end

          # free form text giving additional information about this attribute or its assignment	string
          def comments
            @data['comments']
          end

        end
      end
    end
  end
end
