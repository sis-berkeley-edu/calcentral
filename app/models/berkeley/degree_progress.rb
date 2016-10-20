module Berkeley
  class DegreeProgress

    def self.get_status(status_code)
      statuses[status_code.strip.upcase] unless status_code.blank?
    end

    def self.get_description(milestone_code)
      milestones[milestone_code.strip.upcase] unless milestone_code.blank?
    end

    def self.get_merged_description
      'Advancement to Candidacy Plan I or Plan II'
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
        'AAGDISSERT' => 'Dissertation File Date'
      }
    end

    def self.statuses
      @statuses ||= {
        'Y' => 'Completed',
        'N' => 'Not Satisfied'
      }
    end
  end
end
