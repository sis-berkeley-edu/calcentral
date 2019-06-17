module MyAcademics
  class GpaUnits < UserSpecificModel
    include ClassLogger
    include User::Identifiers
    include Concerns::Careers

    def merge(data)
      data[:gpaUnits] = gpa_units
    end

    def gpa_units
      academic_statuses = MyAcademics::MyAcademicStatus.academic_statuses(@uid)
      academic_status_first = academic_statuses.try(:first)

      result = {
        :errored => MyAcademics::MyAcademicStatus.errored?(@uid),
        :gpa => parse_cumulative_gpa(academic_statuses),
        :totalUnitsTakenNotForGpa => parse_total_units_not_for_gpa(pnp_units, 'pnp_taken'),
        :totalUnitsPassedNotForGpa => parse_total_units_not_for_gpa(pnp_units, 'pnp_passed'),
        :totalTransferAndTestingUnits => units_transferred
      }
      result.merge!(get_cumulative_units)
      result.merge!(parse_total_transfer_units academic_status_first)
      result.merge!(parse_total_units_for_gpa academic_status_first)
      result
    end

    def pnp_units
      # P/NP units from the Hub are calculated differently than desired, so we grab them from an EDODB view instead
      # EDODB P/NP units take into account repeat courses, making them more accurate than the values obtained from the Hub
      if (campus_solutions_id = get_campus_solutions_id)
        EdoOracle::Queries.get_pnp_unit_count(campus_solutions_id)
      end
    end

    def units_transferred
      return nil if law_student?
      feed = EdoOracle::TransferCredit.new(user_id: @uid).get_feed
      grad_transfer_units = feed.try(:[], :graduate).try(:[], :summary).try(:[], :totalTransferUnits) || 0
      undergrad_transfer_units = feed.try(:[], :undergraduate).try(:[], :summary).try(:[], :totalTransferUnits) || 0
      undergrad_test_units = feed.try(:[], :undergraduate).try(:[], :summary).try(:[], :totalTestUnits) || 0
      grad_transfer_units.to_f + undergrad_transfer_units.to_f + undergrad_test_units.to_f
    end

    def get_campus_solutions_id
      lookup_campus_solutions_id
    end

    def parse_cumulative_gpa(statuses)
      gpa = []
      statuses.try(:each) do |status|
        role = status.try(:[], 'studentCareer').try(:[], :role)
        gpa.push(
          {
            role: role,
            roleDescr: role == 'concurrent' ? 'UCB Extension' : status.try(:[], 'studentCareer').try(:[], 'academicCareer').try(:[], 'formalDescription'),
            cumulativeGpa: status.try(:[], 'cumulativeGPA').try(:[], 'average').try(:to_s)
          })
      end
      gpa
    end

    def get_cumulative_units
      careers = active_or_all EdoOracle::Career.new(user_id: @uid).get_cumulative_units
      result = {
        totalUnits: 0,
        totalLawUnits: 0
      }
      careers.each do |career|
        result[:totalUnits] += (career['total_cumulative_units']).to_f
        result[:totalLawUnits] += (career['total_cumulative_law_units']).to_f
      end
      result
    end

    def parse_total_transfer_units(status)
      if (units = status.try(:[], 'cumulativeUnits')) && (total = units.find { |u| u['type'] && u['type']['code'] == 'Total'})
        transfer_units_accepted = total.try(:[], 'unitsTransferAccepted').to_f
        testing_units = total.try(:[], 'unitsTest').to_f
      end
      {
        transferUnitsAccepted: transfer_units_accepted,
        testingUnits: testing_units
      }
    end

    def parse_total_units_for_gpa(status)
      if (units = status.try(:[], 'cumulativeUnits')) && (total = units.find { |u| u['type'] && u['type']['code'] == 'For GPA'})
        total_units_attempted = total.try(:[], 'unitsTaken').to_f
        total_units_for_gpa = total.try(:[], 'unitsPassed').to_f
      end
      {
        totalUnitsAttempted: total_units_attempted,
        totalUnitsForGpa: total_units_for_gpa
      }
    end

    def parse_total_units_not_for_gpa(edo_response, key)
      return nil if law_student?
      units = edo_response.try(:[], key)
      if units
        units.to_f
      end
    end

    def law_student?
      roles = MyAcademics::MyAcademicRoles.new(@uid).get_feed
      !!roles[:current]['law']
    end
  end
end
