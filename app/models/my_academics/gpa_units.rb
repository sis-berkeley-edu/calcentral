module MyAcademics
  class GpaUnits
    include AcademicsModule
    include ClassLogger
    include User::Student

    def merge(data)
      gpa = hub_gpa_units
      prefer_legacy_data = Settings.features.cs_academic_profile_prefers_legacy
      if (current_term.legacy? || prefer_legacy_data) && legacy_user?
        legacy_gpa = oracle_gpa_units
        if gpa[:empty] || (prefer_legacy_data && !legacy_gpa[:empty])
          gpa = legacy_gpa
        end
      end
      data[:gpaUnits] = gpa
    end

    def hub_gpa_units
      response = HubEdos::AcademicStatus.new(user_id: @uid).get
      if (status = parse_hub_academic_status response)
        # GPA is passed as a string to force a decimal point for whole values.
        response[:cumulativeGpa] = (cumulativeGpa = parse_hub_cumulative_gpa status) && cumulativeGpa.to_s
        response[:totalUnits] = (totalUnits = parse_hub_total_units status) && totalUnits.to_f
      else
        response[:empty] = true
      end
      response.delete(:feed)
      response
    end

    def parse_hub_cumulative_gpa(status)
      status['cumulativeGPA'].try(:[], 'average')
    end

    def parse_hub_total_units(status)
      if (units = status['cumulativeUnits']) && (total_units = units.find { |u| u['type'] && u['type']['code'] == 'Total'})
        total_units['unitsPassed']
      end
    end

    def oracle_gpa_units
      student_info = CampusOracle::Queries.get_student_info(@uid) || {}
      {
        cumulativeGpa: student_info['cum_gpa'].nil? ? nil: student_info['cum_gpa'].to_s,
        totalUnits: student_info['tot_units'].nil? ? nil : student_info['tot_units'].to_f,
        totalUnitsAttempted: student_info['lgr_tot_attempt_unit'].nil? ? nil : student_info['lgr_tot_attempt_unit'].to_f
      }
    end

  end
end
