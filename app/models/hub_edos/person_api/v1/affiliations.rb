module HubEdos
  module PersonApi
    module V1
      class Affiliations
        attr_reader :data

        def initialize(data = [])
          @data = data
        end

        def student_affiliation_present?
          all.find(&:is_student?).present?
        end

        def matriculated_but_excluded?
          all.find(&:matriculated_but_excluded?).present?
        end

        def all
          @all ||= data.collect do |affiliation_data|
            ::HubEdos::PersonApi::V1::Affiliation.new(affiliation_data)
          end
        end
      end
    end
  end
end
