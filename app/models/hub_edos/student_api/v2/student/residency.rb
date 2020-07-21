module HubEdos
  module StudentApi
    module V2
      module Student
        # A Residency describes a student's primary place of residence for official purposes.
        class Residency
          def initialize(data)
            @data = data || {}
          end

          # a short descriptor representing the how this residency was established, such as self-reported or official
          def source
            ::HubEdos::Common::Reference::Descriptor.new(@data['source']) if @data['source']
          end

          # the term on which this residency goes into effect
          def from_term
            ::HubEdos::StudentApi::V2::Term::Term.new(@data['fromTerm']) if @data['fromTerm']
          end

          # the date on which the residency goes into effect
          def from_date
            @from_date ||= begin
              Date.parse(@data['fromDate']) if @data['fromDate']
            end
          end

          # a short descriptor representing the overall official residency, such as resident or non-resident
          def official
            ::HubEdos::Common::Reference::Descriptor.new(@data['official']) if @data['official']
          end

          # a short descriptor representing residency for federal financial aid purposes
          def financial_aid
            ::HubEdos::Common::Reference::Descriptor.new(@data['financialAid']) if @data['financialAid']
          end

          # a short descriptor representing the reason for a residency exception for federal financial aid purposes
          def financial_aid_exception
            ::HubEdos::Common::Reference::Descriptor.new(@data['financialAidException']) if @data['financialAidException']
          end

          # a short descriptor representing residency for tuition calculation purpose
          def tuition
            ::HubEdos::Common::Reference::Descriptor.new(@data['tuition']) if @data['tuition']
          end

          # a short descriptor representing the reason for a residency exception for tuition calculation purposes
          def tuition_exception
            ::HubEdos::Common::Reference::Descriptor.new(@data['tuitionException']) if @data['tuitionException']
          end

          # the county of residence within California
          def county
            @data['county']
          end

          # a code indicating the state of residence within the USA
          def state_code
            @data['stateCode']
          end

          # a code indicating the country of residence
          def country_code
            @data['countryCode']
          end

          # a code indicating the particular location of residence
          def postal_code
            @data['postCode']
          end

          # a short descriptor representing the status of the student's Statement of Legal Residence
          def statement_of_legal_residence_status
            ::HubEdos::Common::Reference::Descriptor.new(@data['statementOfLegalResidenceStatus']) if @data['statementOfLegalResidenceStatus']
          end

          # free-form comments about this residency
          def comments
            @data['comments']
          end

        end
      end
    end
  end
end
