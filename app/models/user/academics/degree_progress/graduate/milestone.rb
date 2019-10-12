module User
  module Academics
    module DegreeProgress
      module Graduate
        class Milestone
          attr_reader :data, :user

          def self.safe_iso8601_date_parse(date)
            date_time = nil
            begin
              date_time = DatedFeed.strptime_in_time_zone(date, '%F') if date.present?
            rescue
              Rails.logger.error "Bad date format: #{date}"
            end
            date_time
          end

          def self.format_date(date_time)
            DatedFeed.shared_format_date(date_time, '%b %d, %Y')[:dateString]
          end

          def initialize(data, user)
            @user = user
            @data = data
          end

          def has_requirements?
            requirements.count > 0
          end

          def academic_career_code
            data[:acadCareer]
          end

          def academic_program_code
            data[:acadProgCode]
          end

          def academic_plan_code
            data[:acadPlanCode]
          end

          def academic_program_description
            data[:acadProg]
          end

          def academic_plan_description
            data[:acadPlan]
          end

          def academic_degree_status
            data[:acadDegreeStatus]
          end

          def requirements
            data[:requirements].map do |requirement|
              ::User::Academics::DegreeProgress::Graduate::Requirement.new(requirement, self, user)
            end.select {|r| r.name.present? }
          end

          def qualifying_exam_results_requirement
            requirements.find {|r| r.qualifying_exam_results? }
          end

          def qualifying_exam_approval_requirement
            requirements.find {|r| r.qualifying_exam_approval? }
          end

          def as_json(options={})
            {
              acadCareer: academic_career_code,
              acadDegreeStatus: academic_degree_status,
              acadPlan: academic_plan_description,
              acadPlanCode: academic_plan_code,
              acadProg: academic_program_description,
              acadProgCode: academic_program_code,
              requirements: requirements.map(&:as_json),
            }
          end
        end
      end
    end
  end
end
