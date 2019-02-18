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
      @has_units = false
    end

    def get_feed
      detailed = get_transfer_credit_detailed
      summary = get_transfer_credit_summary
      {
        hasUnits: @has_units,
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
          requirementDesignation: is_law ? credit['requirement_designation'] : nil,
          termId: is_law ? credit['term_id'] : nil,
          termDescription: is_law ? term_description(credit['term_id']) : nil
        }
      end
      result
    end

    def has_units?(result)
      all_units = result[:totalCumulativeUnits].to_i +
        result[:totalTransferUnits].to_i +
        result[:totalTransferUnitsNonAdjusted].to_i +
        result[:apTestUnits].to_i +
        result[:ibTestUnits].to_i +
        result[:alevelTestUnits].to_i +
        result[:totalTestUnits].to_i +
        result[:totalTransferUnitsLaw].to_i
      (all_units > 0)
    end

    def get_transfer_credit_summary
      result = {}
      return result unless careers

      careers.try(:each) do |summary|
        career = summary['acad_career']
        next unless (career_description = CAREERS.try(:[], career.try(:intern)))
        next if law_student? && !(career_whitelist.include? career)

        is_undergrad = :UGRD == career.try(:intern)
        total_transfer_units = summary['total_transfer_units'].try(:to_f)
        transfer_units_adjustment = (summary['transfer_units_adjustment'] || 0).try(:to_f)
        ap_test_units = summary['ap_test_units'].try(:to_f)
        ib_test_units = summary['ib_test_units'].try(:to_f)
        alevel_test_units = summary['alevel_test_units'].try(:to_f)

        result[career_description.downcase] = {
          :career => career,
          :careerDescr => career_description,
          :totalCumulativeUnits => is_undergrad ? summary['total_cumulative_units'].try(:to_f) : nil,
          :totalTransferUnits => total_transfer_units - transfer_units_adjustment,
          :totalTransferUnitsNonAdjusted => transfer_units_adjustment > 0 ? total_transfer_units : nil,
          :apTestUnits => is_undergrad ? ap_test_units : nil,
          :ibTestUnits => is_undergrad ? ib_test_units : nil,
          :alevelTestUnits => is_undergrad ? alevel_test_units : nil,
          :totalTestUnits => is_undergrad ? ap_test_units + ib_test_units + alevel_test_units : nil,
          :totalTransferUnitsLaw => summary['total_transfer_units_law'].try(:to_f)
        }
        @has_units ||= has_units?(result[career_description.downcase])
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

    private

    def term_description(term_id)
      data = Berkeley::TermCodes.from_edo_id(term_id)
      Berkeley::TermCodes.to_english(data[:term_yr], data[:term_cd])
    end
  end
end
