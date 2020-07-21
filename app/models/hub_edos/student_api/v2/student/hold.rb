module HubEdos
  module StudentApi
    module V2
      module Student
        # A Hold is a restriction from obtaining services or credentials due to a failure to comply with an administrative or academic policy
        class Hold
          def initialize(data)
            @data = data || {}
          end

          # a short descriptor representing the kind of hold, such as academic, financial, etc.
          def type
            ::HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
          end

          # a short descriptor representing the policy compliance issue, such as minimum progress, payment of fees, etc.
          def reason
            ::HubEdos::Common::Reference::Descriptor.new(@data['reason']) if @data['reason']
          end

          # An Impact is a short descriptor representing the services restricted as a result of a block, such as future enrollment, viewing grades, etc.
          def impacts
            ::HubEdos::Common::Reference::Descriptor.new(@data['impacts']) if @data['impacts']
          end

          # a component that describes the term the hold goes into effect
          def from_term
            ::HubEdos::StudentApi::V2::Term::Term.new(@data['fromTerm']) if @data['fromTerm']
          end

          # a component that describes the term the hold goes out of effect
          def to_term
            ::HubEdos::StudentApi::V2::Term::Term.new(@data['toTerm']) if @data['toTerm']
          end

          # the date on which the hold goes into effect	date
          def from_date
            @from_date ||= begin
              Date.parse(@data['fromDate']) if @data['fromDate']
            end
          end

          # the date on which the hold goes out of effect	date
          def to_date
            @from_date ||= begin
              Date.parse(@data['toDate']) if @data['toDate']
            end
          end

          # information specifying a document or action associated with the hold
          def reference
            @data['reference']
          end

          # US dollar amount to be remitted in order to clear the hold
          def amount_required
            @data['amountRequired'].to_f
          end

          # a short descriptor representing the department that set the hold
          def department
            ::HubEdos::Common::Reference::Descriptor.new(@data['department']) if @data['department']
          end

          # a short descriptor representing the person or office to contact concerning the hold
          def contact
            ::HubEdos::Common::Reference::Descriptor.new(@data['contact']) if @data['contact']
          end

          # free form comments concerning the hold
          def comments
            @data['comments']
          end

        end
      end
    end
  end
end
