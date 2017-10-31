module MyAcademics
  class GpaUnits < UserSpecificModel
    include ClassLogger
    include User::Identifiers
    include Concerns::AcademicStatus

    def merge(data)
      gpa = hub_gpa_units
      data[:gpaUnits] = gpa
    end

    def hub_gpa_units
      hub_response = MyAcademics::MyAcademicStatus.new(@uid).get_feed
      # P/NP units from the Hub are calculated differently than desired, so we grab them from an EDODB view instead
      # EDODB P/NP units take into account repeat courses, making them more accurate than the values obtained from the Hub
      edo_response = EdoOracle::Queries.get_pnp_unit_count(get_campus_solutions_id)
      result = {}
      #copy needed fields from response obj
      result[:errored] = hub_response[:errored]
      # TODO: Consult with SR concerning GPA displayed when multiple academic careers present
      if (hub_status = academic_statuses(hub_response).try(:first))
        # GPA is passed as a string to force a decimal point for whole values.
        result[:cumulativeGpa] = (cumulativeGpa = parse_hub_cumulative_gpa hub_status) && cumulativeGpa.to_s
        if (totalUnits = parse_hub_total_units hub_status) && totalUnits.present?
          result = result.merge(totalUnits)
        end
        if (totalUnitsForGpa = parse_hub_total_units_for_gpa hub_status) && totalUnitsForGpa.present?
          result = result.merge(totalUnitsForGpa)
        end
      else
        result[:hub_empty] = true
      end
      if (edo_response)
        if (totalUnitsTakenNotForGpa = parse_edo_total_units_taken_not_for_gpa edo_response) && totalUnitsTakenNotForGpa.present?
          result[:totalUnitsTakenNotForGpa] = totalUnitsTakenNotForGpa
        end
        if (totalUnitsPassedNotForGpa = parse_edo_total_units_passed_not_for_gpa edo_response) && totalUnitsPassedNotForGpa.present?
          result[:totalUnitsPassedNotForGpa] = totalUnitsPassedNotForGpa
        end
      else
        result[:edo_empty] = true
      end
      result
    end

    def get_campus_solutions_id
      lookup_campus_solutions_id
    end

    def parse_hub_cumulative_gpa(status)
      status['cumulativeGPA'].try(:[], 'average')
    end

    # Ignores unimportant unit types given back by the hub, including 'unitsOther' (holds total units that exceed limits for other categories, e.g. transfer units)
    def parse_hub_total_units(status)
      if (units = status['cumulativeUnits']) && (total_units = units.find { |u| u['type'] && u['type']['code'] == 'Total'})
        {
          totalUnits: total_units['unitsCumulative'].to_f,
          transferUnitsAccepted: total_units['unitsTransferAccepted'].to_f,
          testingUnits: total_units['unitsTest'].to_f
        }
      end
    end

    def parse_hub_total_units_for_gpa(status)
      if (units = status['cumulativeUnits']) && (total_units = units.find { |u| u['type'] && u['type']['code'] == 'For GPA'})
        {
          totalUnitsAttempted: total_units['unitsTaken'].to_f,
          totalUnitsForGpa: total_units['unitsPassed'].to_f
        }
      end
    end

    def parse_edo_total_units_taken_not_for_gpa(edo_response)
      if (units = edo_response["pnp_taken"])
        units.to_f
      end
    end

    def parse_edo_total_units_passed_not_for_gpa(edo_response)
      if (units = edo_response["pnp_passed"])
        units.to_f
      end
    end

  end
end
