module HubEdos
  module StudentApi
    module V2
      module StudentRecord
        # An Institution describes a high school, college, or university that grants academic credit.
        class Institution
          def initialize(data)
            @data = data
          end

          # a short string used to identify the institution
          def code
            @data['code']
          end

          # the full name of the institution
          def name
            @data['name']
          end

          # A School Type describes the kind of educational institution
          def school_type
            ::HubEdos::StudentApi::V2::Term::Term.new(@data['schoolType']) if @data['schoolType']
          end

          # further explanatory information about the institution
          def description
            @data['description']
          end

          #	a component that describes the institution's location, see Address in the Contact component description
          def addresss
            ::HubEdos::StudentApi::V2::Term::Term.new(@data['schoolType']) if @data['schoolType']
          end

          # a standardized 4-6 digit ID assigned to the institution by the Educational Testing Service
          def ceeb_code
            @data['ceebCode']
          end

          # a 6 digit ID used by the Federal Interagency Committee on Education during the early sixties (included only for archival reference)
          def fice_code
            @data['ficeCode']
          end

        end
      end
    end
  end
end
