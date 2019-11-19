module User
  module Academics
    module DegreeProgress
      module Graduate
        class Milestones
          attr_reader :user

          CAREER_LAW = 'LAW'
          ACAD_PROG_CODE_LACAD = 'LACAD'

          # Returns true for milestones related to Law Self-Supporting, Professional, and Non-Degree Programs
          def self.filter_law_nonacademic(milestone)
            milestone.academic_career_code == CAREER_LAW && milestone.academic_program_code != ACAD_PROG_CODE_LACAD
          end

          def initialize(user)
            @user = user
          end

          def user
            @user
          end

          def as_json(options={})
            all_except_law_nonacademic.collect(&:as_json)
          end

          def all
            api_results.map do |data|
              ::User::Academics::DegreeProgress::Graduate::Milestone.new(data, user)
            end.select {|milestone| milestone.has_requirements? }
          end

          def all_except_law_nonacademic
            all.reject {|milestone| self.class.filter_law_nonacademic(milestone) }
          end

          def api_results
            @api_results ||= MilestonesCached.new(@user).get_feed
          end
        end
      end
    end
  end
end
