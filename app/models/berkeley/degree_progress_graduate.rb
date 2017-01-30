module Berkeley
  class DegreeProgressGraduate

    def self.get_status(status_code)
      statuses[status_code.strip.upcase] unless status_code.blank?
    end

    def self.get_description(milestone_code)
      milestones[milestone_code.strip.upcase] unless milestone_code.blank?
    end

    def self.get_merged_description
      'Advancement to Candidacy Plan I or Plan II'
    end

    def self.get_form_notification(milestone_code, status_code)
      form_notifications[milestone_code.strip.upcase] unless (status_code === 'Y' || milestone_code.blank?)
    end

    def self.get_merged_form_notification
      '(Plan 1 Requires a Form)'
    end

    def self.milestones
      @milestones ||= {
        'AAGADVMAS1' => 'Advancement to Candidacy Plan I',
        'AAGADVMAS2' => 'Advancement to Candidacy Plan II',
        'AAGFINALCK' => 'Department Final Recommendations',
        'AAGACADP1' => 'Thesis File Date',
        'AAGQEAPRV' => 'Approval for Qualifying Exam',
        'AAGQERESLT' => 'Qualifying Exam Results',
        'AAGADVPHD' => 'Advancement to Candidacy',
        'AAGFINALCK' => 'Department Final Recommendations',
        'AAGDISSERT' => 'Dissertation File Date',
        'AAGACADP2' => 'Capstone'
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
