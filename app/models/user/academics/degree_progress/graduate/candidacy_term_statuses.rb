module User
  module Academics
    module DegreeProgress
      module Graduate
        class CandidacyTermStatuses
          attr_reader :user

          def initialize(user)
            @user = user
          end

          def all
            query_results.map do |data|
              ::User::Academics::DegreeProgress::Graduate::CandidacyTermStatus.new(data)
            end
          end

          def first
            all.first
          end

          def query_results
            @query_results ||= CandidacyTermStatusesCached.new(user).get_feed
          end
        end
      end
    end
  end
end
