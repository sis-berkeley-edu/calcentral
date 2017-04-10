module Berkeley
  class GraduateMilestones

    STATUS_CODE_COMPLETE = 'Y'
    QE_RESULTS_STATUS_CODE_PASSED = 'P'

    QE_RESULTS_STATUS_FAILED = 'Failed'
    QE_RESULTS_STATUS_PARTIALLY_FAILED = 'Partially Failed'
    QE_RESULTS_STATUS_PASSED = 'Passed'
    STATUS_INCOMPLETE = 'Not Satisfied'

    QE_APPROVAL_MILESTONE = 'AAGQEAPRV'
    QE_RESULTS_MILESTONE = 'AAGQERESLT'

    def self.get_status(status_code, milestone_code = nil)
      status_code_standardized = status_code.strip.upcase unless status_code.blank?

      if milestone_code === QE_APPROVAL_MILESTONE
        qualifying_exam_approval_statuses.try(:[], status_code_standardized)
      elsif milestone_code === QE_RESULTS_MILESTONE
        qualifying_exam_results_statuses.try(:[], status_code_standardized)
      else
        statuses.try(:[], status_code_standardized)
      end
    end

    def self.get_description(milestone_code)
      milestones.try(:[], milestone_code.strip.upcase).try(:[], :milestone) unless milestone_code.blank?
    end

    def self.get_order_number(milestone_code)
      milestones.try(:[], milestone_code.strip.upcase).try(:[], :order) unless milestone_code.blank?
    end

    def self.get_form_notification(milestone_code, status_code)
      form_notifications.try(:[], milestone_code.strip.upcase) unless (status_code === 'Y' || milestone_code.blank?)
    end

    def self.milestones
      @milestones ||= {
        'AAGADVMAS1' => {
          :milestone => 'Advancement to Candidacy (Thesis Plan)',
          :order => 2
        },
        'AAGADVMAS2' => {
          :milestone => 'Advancement to Candidacy (Capstone Plan)',
          :order => 3
        },
        'AAGACADP1' => {
          :milestone => 'Thesis File Date',
          :order => 5
        },
        QE_APPROVAL_MILESTONE => {
          :milestone => 'Approval for Qualifying Exam',
          :order => 1
        },
        QE_RESULTS_MILESTONE => {
          :milestone => 'Qualifying Exam Results',
          :order => 2
        },
        'AAGADVPHD' => {
          :milestone => 'Advancement to Candidacy',
          :order => 3
        },
        'AAGDISSERT' => {
          :milestone => 'Dissertation File Date',
          :order => 5
        },
        'AAGACADP2' => {
          :milestone => 'Capstone',
          :order => 6
        },
      }
    end

    def self.qualifying_exam_approval_statuses
      @qualifying_exam_approval_statuses ||= {
        'N' => STATUS_INCOMPLETE,
        STATUS_CODE_COMPLETE => 'Approved'
      }
    end

    def self.qualifying_exam_results_statuses
      @qualifying_exam_results_statuses ||= {
        'F' => QE_RESULTS_STATUS_FAILED,
        'PF' => QE_RESULTS_STATUS_PARTIALLY_FAILED,
        QE_RESULTS_STATUS_CODE_PASSED => QE_RESULTS_STATUS_PASSED
      }
    end

    def self.statuses
      @statuses ||= {
        'N' => STATUS_INCOMPLETE,
        STATUS_CODE_COMPLETE => 'Completed'
      }
    end

    def self.form_notifications
      @form_notifications ||= {
        'AAGADVMAS1' => '(Form Required)',
        'AAGQEAPRV' => '(Form Required)'
      }
    end
  end
end
