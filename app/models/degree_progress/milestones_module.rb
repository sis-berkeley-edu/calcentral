module DegreeProgress
  module MilestonesModule
    include DatedFeed

    CAREER_LAW = 'LAW'
    ACAD_PROG_CODE_LACAD = 'LACAD'

    def process(response)
      degree_progress = response.try(:[], :feed).try(:[], :ucAaProgress).try(:[], :progresses)
      massage_progresses(degree_progress)
    end

    def massage_progresses(degree_progress)
      result = []
      if !!degree_progress
        degree_progress.each do |progress|
          if should_exclude progress
            next
          end

          result.push(progress).last.tap do |prog|
            prog[:requirements] = normalize(prog.fetch(:requirements))
          end
        end
      end
      result
    end

    def should_exclude(progress)
      CAREER_LAW == progress[:acadCareer] && ACAD_PROG_CODE_LACAD != progress[:acadProgCode]
    end

    def normalize(requirements)
      normalized_requirements = requirements.map do |requirement|
        name = Berkeley::GraduateMilestones.get_description(requirement[:code])
        if name
          normalized = {
            name: name,
            code: requirement[:code],
            status:  Berkeley::GraduateMilestones.get_status(requirement[:status]),
            orderNumber: Berkeley::GraduateMilestones.get_order_number(requirement[:code]),
            dateCompleted: parse_date(requirement[:dateCompleted]),
            dateAnticipated: parse_date(requirement[:dateAnticipated]),
            formNotification: Berkeley::GraduateMilestones.get_form_notification(requirement[:code], requirement[:status]),
            attempts: parse_milestone_attempts(requirement)
          }
          normalized[:statusCode] = determine_status_code(requirement[:status], normalized[:attempts])
          normalized
        end
      end.compact
      set_proposed_exam_date(normalized_requirements)
      normalized_requirements
    end

    def parse_date(date)
      pretty_date = ''
      begin
         pretty_date = format_date(strptime_in_time_zone(date, '%F'), '%b %d, %Y')[:dateString] unless date.blank?
      rescue
        logger.error "Bad date format: #{date} in class #{self.class.name}, uid = #{@uid}"
      end
      pretty_date
    end

    def parse_milestone_attempts(requirement)
      qualifying_exam_attempts = []
      if qualifying_exam?(requirement)
        qualifying_exam_attempts = requirement[:attempts].try(:map) do |attempt|
          parse_milestone_attempt(attempt)
        end
        qualifying_exam_attempts.try(:sort_by!) do |attempt|
          attempt[:sequenceNumber]
        end.try(:reverse!)
      end
      qualifying_exam_attempts
    end

    def qualifying_exam?(requirement)
      requirement[:code].to_s.strip.upcase === Berkeley::GraduateMilestones::QE_RESULTS_MILESTONE
    end

    def parse_milestone_attempt(milestone_attempt)
      milestone_attempt = {
        sequenceNumber: milestone_attempt[:attemptNbr].to_i,
        date: parse_date(milestone_attempt[:attemptDate]),
        result: Berkeley::GraduateMilestones.get_status(milestone_attempt[:attemptStatus]),
        statusCode: milestone_attempt[:attemptStatus]
      }
      milestone_attempt[:display] = format_milestone_attempt(milestone_attempt)
      milestone_attempt
    end

    def format_milestone_attempt(milestone_attempt)
      if milestone_attempt[:result] == Berkeley::GraduateMilestones::QE_STATUS_PASSED
        "#{milestone_attempt[:result]} #{milestone_attempt[:date]}"
      else
        "Exam #{milestone_attempt[:sequenceNumber]}: #{milestone_attempt[:result]} #{milestone_attempt[:date]}"
      end
    end

    def determine_status_code(status_code, milestone_attempts)
      return status_code unless status_code.blank?
      latest_attempt = milestone_attempts.first unless milestone_attempts.blank?
      return latest_attempt.try(:[], :statusCode)
    end

    def set_proposed_exam_date(requirements)
      qualifying_exam_approval_milestone = requirements.select do |requirement|
        requirement.try(:[], :code) === Berkeley::GraduateMilestones::QE_APPROVAL_MILESTONE
      end.first
      if qualifying_exam_approval_milestone
        qualifying_exam_results_milestone = requirements.select do |requirement|
          requirement.try(:[], :code) === Berkeley::GraduateMilestones::QE_RESULTS_MILESTONE
        end.first
        exam_passed = qualifying_exam_results_milestone.try(:[], :statusCode) === Berkeley::GraduateMilestones::QE_STATUS_CODE_PASSED
        qualifying_exam_approval_milestone[:proposedExamDate] = qualifying_exam_approval_milestone.try(:[], :dateAnticipated) unless exam_passed
      end
    end
  end
end
