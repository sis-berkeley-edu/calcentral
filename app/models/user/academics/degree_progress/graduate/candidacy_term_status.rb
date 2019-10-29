module User
  module Academics
    module DegreeProgress
      module Graduate
        class CandidacyTermStatus
          attr_reader :data

          def initialize(data)
            @data = data
          end

          def status_code
            @data['candidacy_status_code']
          end

          def end_term_code
            @data['candidacy_end_term']
          end

          def academic_career_code
            @data['acad_career']
          end

          def academic_program_code
            @data['acad_prog']
          end

          def academic_plan_code
            @data['acad_plan']
          end

          def end_term
            @end_term ||= Berkeley::Terms.find_by_campus_solutions_id(end_term_code)
          end

          def end_term_description
            end_term.try(:to_english)
          end

          def candidacy_status_description
            case status_code
              when 'G'
                'Good'
              when 'L'
                'Lapsed'
              when 'E'
                'Extended'
              when 'R'
                'Reinstated'
              when 'T'
                'Terminated'
              else
                Rails.logger.error "Unknown candidacy status code '#{status_code}' for EMPLID #{data['emplid']} in term #{data['candidacy_end_term']}"
                'Unknown'
            end
          end

          def as_json(options={})
            {
              academicCareerCode: academic_career_code,
              academicProgramCode: academic_program_code,
              academicPlanCode: academic_plan_code,
              statusDescription: candidacy_status_description,
              endTermDescription: end_term_description,
            }
          end
        end
      end
    end
  end
end
