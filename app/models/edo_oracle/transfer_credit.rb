module EdoOracle
  class TransferCredit < BaseProxy
    include ClassLogger
    include User::Identifiers

    CAREERS = {
      :UGRD => :Undergraduate,
      :GRAD => :Graduate,
      :LAW => :Law
    }

    def initialize(options = {})
      super(Settings.edodb, options)
    end

    def get_feed
      detailed = get_transfer_credit_detailed
      summary = get_transfer_credit_summary
      {
        undergraduate: {
          detailed: detailed[:undergraduate],
          summary: summary[:undergraduate]
        },
        graduate: {
          detailed: detailed[:graduate],
          summary: summary[:graduate]
        },
        law: {
          detailed: detailed[:law],
          summary: summary[:law]
        }
      }
    end

    def get_transfer_credit_detailed
      result = {}
      return result unless (transfer_credits = EdoOracle::Queries.get_transfer_credit_detailed @uid)

      transfer_credits.try(:each) do |credit|
        career = credit['career']

        next unless (career_description = CAREERS.try(:[], career.try(:intern)).try(:downcase))
        next if law_student? && !(career_whitelist.include? career)

        is_law = :LAW == career.try(:intern)
        result[career_description] ||= []
        result[career_description] << {
          school: credit['school_descr'],
          units: credit['transfer_units'].try(:to_f),
          gradePoints: is_law ? nil : credit['grade_points'].try(:to_f),
          lawUnits: is_law ? credit['law_transfer_units'].try(:to_f) : nil,
          requirementDesignation: is_law ? credit['requirement_designation'] : nil
        }
      end
      result
    end

    def get_transfer_credit_summary
      result = {}
      return result unless careers

      careers.try(:each) do |summary|
        career = summary['acad_career']
        next unless (career_description = CAREERS.try(:[], career.try(:intern)))
        next if law_student? && !(career_whitelist.include? career)

        is_undergrad = :UGRD == career.try(:intern)
        result[career_description.downcase] = {
          :career => career,
          :careerDescr => career_description,
          :totalCumulativeUnits => is_undergrad ? summary['total_cumulative_units'].try(:to_f) : nil,
          :totalTransferUnits => summary['total_transfer_units'].try(:to_f),
          :transferUnitsAdjusted => summary['transfer_units_adjusted'].try(:to_f),
          :apTestUnits => is_undergrad ? summary['ap_test_units'].try(:to_f) : nil,
          :ibTestUnits => is_undergrad ? summary['ib_test_units'].try(:to_f) : nil,
          :alevelTestUnits => is_undergrad ? summary['alevel_test_units'].try(:to_f) : nil,
          :totalTransferUnitsLaw => summary['total_transfer_units_law'].try(:to_f)
        }
      end
      result
    end

    def careers
      @careers ||= EdoOracle::Career.new(user_id: @uid).fetch
    end

    def career_whitelist
      get_careers = Proc.new do
        active_or_all_careers = Concerns::Careers.active_or_all careers
        active_or_all_careers.try(:map) {|career| career.try(:[], 'acad_career')}
      end
      @career_whitelist ||= get_careers.call
    end

    def law_student?
      roles = MyAcademics::MyAcademicRoles.new(@uid).get_feed
      !!roles[:current]['law']
    end
  end
end
