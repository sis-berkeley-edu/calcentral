module Berkeley
  class DegreeProgressGraduate

    def self.get_status(status_code)
      statuses.try(:[], status_code.strip.upcase) unless status_code.blank?
    end

    def self.get_description(milestone_code)
      milestones.try(:[], milestone_code.strip.upcase).try(:[], :milestone) unless milestone_code.blank?
    end

    def self.get_order_number(milestone_code)
      milestones.try(:[], milestone_code.strip.upcase).try(:[], :order) unless milestone_code.blank?
    end

    def self.get_merged_description
      'Advancement to Candidacy Plan I or Plan II'
    end

    def self.get_form_notification(milestone_code, status_code)
      form_notifications.try(:[], milestone_code.strip.upcase) unless (status_code === 'Y' || milestone_code.blank?)
    end

    def self.get_merged_form_notification
      '(Plan 1 Requires a Form)'
    end

    def self.milestones
      @milestones ||= {
        'AAGADVMAS1' => {
          :milestone => 'Advancement to Candidacy Plan I',
          :order => 2
        },
        'AAGADVMAS2' => {
          :milestone => 'Advancement to Candidacy Plan II',
          :order => 3
        },
        'AAGFINALCK' => {
          :milestone => 'Department Final Recommendations',
          :order => 4
        },
        'AAGACADP1' => {
          :milestone => 'Thesis File Date',
          :order => 5
        },
        'AAGQEAPRV' => {
          :milestone => 'Approval for Qualifying Exam',
          :order => 1
        },
        'AAGQERESLT' => {
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

    def self.statuses
      @statuses ||= {
        'F' => 'Failed',
        'PF' => 'Partially Failed',
        'I' => 'In Progress',
        'N' => 'Not Satisfied',
        'P' => 'Passed',
        'S' => 'Partially Passed',
        'Y' => 'Completed'
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
