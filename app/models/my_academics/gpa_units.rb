module MyAcademics
  class GpaUnits
    include AcademicsModule
    include ClassLogger

    def merge(data)
      gpa = hub_gpa_units
      data[:gpaUnits] = gpa
    end

    def hub_gpa_units
      response = HubEdos::MyAcademicStatus.new(@uid).get_feed
      result = {}
      unit_total = 0
      unit_sum = 0
      #copy needed feilds from response obj
      result[:errored] = response[:errored]
      # TODO: Consult with SR concerning GPA displayed when multiple academic careers present
      if (status = parse_hub_academic_statuses(response).try :first)
        # GPA is passed as a string to force a decimal point for whole values.
        result[:cumulativeGpa] = (cumulativeGpa = parse_hub_cumulative_gpa status) && cumulativeGpa.to_s
        if (totalUnits = parse_hub_total_units status) && totalUnits.present?
          result = result.merge(totalUnits)
          unit_total = result[:totalUnits]
          unit_sum += (result[:transferUnitsAccepted] + result[:testingUnits])
        end
        if (totalUnitsForGpa = parse_hub_total_units_for_gpa status) && totalUnitsForGpa.present?
          result = result.merge(totalUnitsForGpa)
          unit_sum += result[:totalUnitsForGpa]
        end
        if (totalUnitsTakenNotForGpa = parse_hub_total_units_taken_not_for_gpa status) && totalUnitsTakenNotForGpa.present?
          result[:totalUnitsTakenNotForGpa] = totalUnitsTakenNotForGpa
        end
        if (totalUnitsPassedNotForGpa = parse_hub_total_units_passed_not_for_gpa status) && totalUnitsPassedNotForGpa.present?
          result[:totalUnitsPassedNotForGpa] = totalUnitsPassedNotForGpa
          unit_sum += result[:totalUnitsPassedNotForGpa]
        end
        if (unit_total != unit_sum)
          logger.warn("Hub unit conflict for UID #{@uid}: Total units (#{unit_total}) does not match summed units (#{unit_sum}).")
        end
      else
        result[:empty] = true
      end
      result
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

    def parse_hub_total_units_taken_not_for_gpa(status)
      if (units = status['cumulativeUnits']) && (total_units = units.find { |u| u['type'] && u['type']['code'] == 'Not For GPA'})
        total_units['unitsTaken'].to_f
      end
    end

    def parse_hub_total_units_passed_not_for_gpa(status)
      if (units = status['cumulativeUnits']) && (total_units = units.find { |u| u['type'] && u['type']['code'] == 'Not For GPA'})
        total_units['unitsPassed'].to_f
      end
    end

  end
end
