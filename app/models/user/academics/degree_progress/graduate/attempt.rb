module User
  module Academics
    module DegreeProgress
      module Graduate
        class Attempt
          attr_reader :data

          def initialize(data)
            @data = data
          end

          def sequence_number
            data[:attemptNbr].to_i
          end

          def date
            Milestone.safe_iso8601_date_parse(data[:attemptDate])
          end

          def date_formatted
            Milestone.format_date(date)
          end

          def status_code
            data[:attemptStatus]
          end

          def qualifying_exam_result
            Berkeley::GraduateMilestones.get_status(status_code, Berkeley::GraduateMilestones::QE_RESULTS_MILESTONE)
          end

          def display_description
            "Exam #{sequence_number}: #{qualifying_exam_result} #{date_formatted}"
          end

          def as_json(options={})
            {
              sequenceNumber: sequence_number,
              statusCode: status_code,
              display: display_description,
            }
          end

        end
      end
    end
  end
end
