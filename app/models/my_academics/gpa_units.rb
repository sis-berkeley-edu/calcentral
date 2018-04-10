module MyAcademics
  class GpaUnits < UserSpecificModel
    include ClassLogger
    include User::Identifiers
    include Concerns::AcademicStatus

    def merge(data)
      data[:gpaUnits] = gpa_units
    end

    def gpa_units
      feed = MyAcademics::MyAcademicStatus.new(@uid).get_feed
      academic_status = parse_academic_status feed

      result = {
        :errored => feed.try(:[], :errored),
        :cumulativeGpa => parse_cumulative_gpa(academic_status),
        :totalUnitsTakenNotForGpa => parse_total_units_not_for_gpa(pnp_units, 'pnp_taken'),
        :totalUnitsPassedNotForGpa => parse_total_units_not_for_gpa(pnp_units, 'pnp_passed'),
        :totalTransferAndTestingUnits => units_transferred
      }
      result.merge!(parse_total_units academic_status)
      result.merge!(parse_total_units_for_gpa academic_status)
      result
    end

    def parse_academic_status(feed)
      #TODO: Consult with SR concerning GPA displayed when multiple academic careers present
      academic_statuses(feed).try(:first)
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
      feed = MyAcademics::TransferCredit.new(@uid).get_feed
      transfer_units = feed.try(:[], :ucTransferCrseSch).try(:[], :unitsAdjusted)
      test_units = feed.try(:[], :ucTestComponent).try(:[], :totalTestUnits)
      if transfer_units || test_units
        transfer_units.to_f + test_units.to_f
      end
    end

    def get_campus_solutions_id
      lookup_campus_solutions_id
    end

    def parse_cumulative_gpa(status)
      status.try(:[], 'cumulativeGPA').try(:[], 'average').try(:to_s)
    end

    # Ignores unimportant unit types given back by the hub, including 'unitsOther' (holds total units that exceed limits for other categories, e.g. transfer units)
    def parse_total_units(status)
      if (units = status.try(:[], 'cumulativeUnits')) && (total = units.find { |u| u['type'] && u['type']['code'] == 'Total'})
        total_units = total.try(:[], 'unitsCumulative').to_f
        transfer_units_accepted = total.try(:[], 'unitsTransferAccepted').to_f
        testing_units = total.try(:[], 'unitsTest').to_f
      end
      {
        totalUnits: total_units,
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
      !!roles['law']
    end
  end
end
