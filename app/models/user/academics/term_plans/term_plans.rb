module User
  module Academics
    module TermPlans
      # Provides a students Career, Program, and Plans (CPP) within
      # the context of a specific term (e.g. Spring, Summer, or Fall)
      class TermPlans
        attr_reader :user

        def initialize(user)
          @user = user
        end

        def all
          query_results.collect do |cpp|
            TermPlan.new(cpp)
          end.sort_by(&:term_id).reverse
        end

        def find_by_term_id_and_career_code(term_id, career_code)
          all.find do |plan|
            plan.term_id == term_id &&
              plan.academic_career_code == career_code
          end
        end

        def latest_career_code
          all.first.academic_career_code
        end

        def current_term
          Berkeley::Terms.fetch.current
        end

        def current_and_future
          all.select {|p| p.term_id.to_s >= current_term.try(:campus_solutions_id).to_s }
        end

        def query_results
          @query_results ||= ::User::Academics::TermPlans::TermPlansCached.new(@user).get_feed || []
        end
      end
    end
  end
end
