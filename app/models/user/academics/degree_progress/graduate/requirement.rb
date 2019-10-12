module User
  module Academics
    module DegreeProgress
      module Graduate
        class Requirement
          attr_reader :data, :milestone, :user

          def initialize(data, milestone, user)
            @data = data
            @milestone = milestone
            @user = user
          end

          def code
            data[:code].to_s.strip.upcase
          end

          def name
            Berkeley::GraduateMilestones.get_description(code)
          end

          def status_code
            return data[:status] if data[:status].present?
            attempts.try(:first).try(:status_code).to_s
          end

          def status_description
            Berkeley::GraduateMilestones.get_status(status_code, code) || Berkeley::GraduateMilestones::STATUS_INCOMPLETE
          end

          def order_number
            Berkeley::GraduateMilestones.get_order_number(code)
          end

          def form_notification
            Berkeley::GraduateMilestones.get_form_notification(code, status_code)
          end

          def date_completed
            Milestone.safe_iso8601_date_parse(data[:dateCompleted])
          end

          def date_completed_formatted
            Milestone.format_date(date_completed).to_s
          end

          def date_anticipated
            Milestone.safe_iso8601_date_parse(data[:dateAnticipated])
          end

          def date_anticipated_formatted
            Milestone.format_date(date_anticipated).to_s
          end

          def proposed_exam_date
            if qualifying_exam_approval? && completed? && !qualifying_exam_attempted?
              return date_anticipated_formatted
            end
          end

          def qualifying_exam_attempted?
            milestone.qualifying_exam_results_requirement.attempts.present?
          end

          def qualifying_exam_results?
            code == Berkeley::GraduateMilestones::QE_RESULTS_MILESTONE
          end

          def qualifying_exam_approval?
            code == Berkeley::GraduateMilestones::QE_APPROVAL_MILESTONE
          end

          def completed?
            status_code == Berkeley::GraduateMilestones::STATUS_CODE_COMPLETE
          end

          def advancement_to_candidacy?
            code == Berkeley::GraduateMilestones::ADVANCEMENT_TO_CANDIDACY
          end

          def milestone_academic_plan_code
            milestone.try(:academic_plan_code)
          end

          def candidacy_term_status
            @candidacy_term_status ||= begin
              if completed? && advancement_to_candidacy?
                if statuses = CandidacyTermStatuses.new(user).all
                  statuses.find {|status| status.academic_plan_code == milestone.academic_plan_code}
                end
              end
            end
          end

          def candidacy_status_description
            candidacy_term_status.try(:statusDescription)
          end

          def candidacy_end_term_description
            candidacy_term_status.try(:endTermDescription)
          end

          def attempts
            data[:attempts].to_a.map do |data|
              ::User::Academics::DegreeProgress::Graduate::Attempt.new(data)
            end.sort_by do |attempt|
              attempt.sequence_number
            end.reverse
          end

          def qualifying_exam_attempts
            qe_attempts = []
            if qualifying_exam_results?
              qe_attempts = attempts.try(:sort_by) do |attempt|
                attempt.sequence_number
              end.try(:reverse!)
            end
            qe_attempts
          end

          def as_json(options={})
            requirement_hash = {
              name: name,
              code: code,
              status: status_description,
              statusCode: status_code,
              orderNumber: order_number,
              dateCompleted: date_completed_formatted,
              dateAnticipated: date_anticipated_formatted,
              formNotification: form_notification,
              attempts: qualifying_exam_attempts.map(&:as_json),
              proposedExamDate: proposed_exam_date,
            }
            if candidacy_term_status.present?
              requirement_hash.merge!({
                candidacyTermStatus: candidacy_term_status.as_json
              })
            end
            requirement_hash
          end
        end
      end
    end
  end
end
