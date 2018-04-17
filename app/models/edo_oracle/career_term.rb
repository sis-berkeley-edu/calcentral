module EdoOracle
  class CareerTerm < BaseProxy
    include ClassLogger

    def initialize(options = {})
      super(Settings.edodb, options)
    end

    def term_summary(academic_careers, term_id)
      general_units = EdoOracle::Queries.get_term_unit_totals(@uid, academic_careers, term_id)
      law_units = EdoOracle::Queries.get_term_law_unit_totals(@uid, academic_careers, term_id)
      {
        total_enrolled_units: general_units.try(:[], 'total_enrolled_units'),
        total_earned_units: general_units.try(:[], 'total_earned_units'),
        grading_complete: 'Y' == general_units.try(:[], 'grading_complete'),
        total_enrolled_law_units: law_units.try(:[], 'total_enrolled_law_units'),
        total_earned_law_units: law_units.try(:[], 'total_earned_law_units')
      }
    end
  end
end
