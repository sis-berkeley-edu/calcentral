module HubEdos
  module StudentApi
    module V2
      module StudentRecord
        # A Matriculation describes when a student first moved from having been admitted to enrolling in classes within an academic career.
        class Matriculation

          def initialize(data)
            @data = data
          end

          # the term during which the student matriculated
          def term
            ::HubEdos::StudentApi::V2::Term::Term.new(@data['term']) if @data['term']
          end

          # a simple descriptor representing the category of entry into the career, such as freshman, transfer, etc.
          def type
            ::HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
          end

          # a simple descriptor representing where the student resided at matriculation
          def home_location
            ::HubEdos::Common::Reference::Descriptor.new(@data['homeLocation']) if @data['homeLocation']
          end

        end
      end
    end
  end
end
