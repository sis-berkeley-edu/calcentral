module Berkeley
  module UserRoles
    extend self
    include ClassLogger

     def base_roles
      {
        advisor: false,
        applicant: false,
        concurrentEnrollmentStudent: false,
        expiredAccount: false,
        exStudent: false,
        faculty: false,
        graduate: false,
        guest: false,
        law: false,
        registered: false,
        releasedAdmit: false,
        staff: false,
        student: false,
        undergrad: false,
        withdrawnAdmit: false,
        preSir: false
      }
    end

    def roles_from_affiliations(affiliations)
      affiliations ||= []
      base_roles.merge({
        :student => affiliations.index {|a| (a.start_with? 'STUDENT-TYPE-')}.present?,
        :registered => affiliations.include?('STUDENT-TYPE-REGISTERED'),
        # TODO Remove '-STATUS-EXPIRED' logic once CalNet transition is complete.
        :exStudent => (affiliations & ['STUDENT-STATUS-EXPIRED', 'FORMER-STUDENT', 'AFFILIATE-TYPE-ADVCON-ALUMNUS']).present?,
        :faculty => affiliations.include?('EMPLOYEE-TYPE-ACADEMIC'),
        :staff => affiliations.include?('EMPLOYEE-TYPE-STAFF'),
        :guest => (affiliations & ['GUEST-TYPE-COLLABORATOR', 'GUEST-TYPE-SOCIAL']).present?
      })
    end

    def roles_from_ldap_affiliations(ldap_record)
      affiliations = ldap_record[:berkeleyeduaffiliations].to_a
      affiliations_map = ['EMPLOYEE', 'AFFILIATE', 'GUEST', 'STUDENT']

      # Remove any affiliations we are choosing to ignore
      if !ldap_student_affiliations_enabled
        affiliations_map.delete('STUDENT')
        affiliations = affiliations.delete_if do |affiliation|
          affiliation.include?('STUDENT')
        end
      end

      # CalNet should no longer provide conflicting affiliations as normal business. If conflicts
      # do appear, we log them and more-or-less arbitrarily choose the "active" version rather than
      # the "no-longer-active" version.
      affiliations_map.each do |aff_substring|
        active_aff = affiliations.select {|aff| aff.start_with? "#{aff_substring}-TYPE-"}
        expired_aff = affiliations.select {|aff| aff == "FORMER-#{aff_substring}" ||
          aff.start_with?("#{aff_substring}-STATUS-")}
        if active_aff.present? && expired_aff.present?
          logger.warn "UID #{ldap_record[:uid]} has conflicting CalNet affiliations #{affiliations}"
          affiliations = affiliations - expired_aff
        end
      end

      roles_from_affiliations affiliations
    end

    def roles_from_ldap_groups(ldap_groups)
      return {} if ldap_groups.nil? || ldap_groups.empty? || !ldap_student_affiliations_enabled

      # Active-but-not-registered students have exactly the same list of memberships as registered students.
      group_prefix = 'cn=edu:berkeley:official:students'
      group_suffix = 'ou=campus groups,dc=berkeley,dc=edu'
      roles = find_matching_roles(ldap_groups, {
        "#{group_prefix}:all,#{group_suffix}" => :student,
        "#{group_prefix}:graduate,#{group_suffix}" => :graduate,
        "#{group_prefix}:undergrad,#{group_suffix}" => :undergrad
      })
      roles
    end

    def roles_from_ldap_ou(ldap_ou)
      return {} if ldap_ou.nil? || ldap_ou.empty?
      { expiredAccount: ldap_ou.include?('expired people') }
    end

    def roles_from_campus_row(campus_row)
      affiliation_string = campus_row['affiliations'] || ''
      roles = roles_from_affiliations(affiliation_string.split ',')
      if roles[:student]
        case campus_row['ug_grad_flag']
          when 'U'
            roles[:undergrad] = true
          when 'G'
            roles[:graduate] = true
        end
      end
      roles[:expiredAccount] = (campus_row['person_type'] == 'Z')
      roles
    end

    def roles_from_cs_affiliations(cs_affiliations)
      return {} unless cs_affiliations
      result = {}

      # Possible CS affiliation status codes: 'ACT' (active), 'INA' (inactive) and 'ERR' (bad data that we should ignore)
      cs_affiliations.select { |a| a[:status][:code] == 'ACT' }.each do |active_affiliation|
        # TODO: We still need to cover staff, guests, concurrent-enrollment students and registration status.
        case active_affiliation[:type][:code]
          when 'ADMT_UX'
            # A 'releasedAdmit' is a user whose Statement of Intent to Register has been released to them
            result[:releasedAdmit] = true
          when 'APPLICANT'
            result[:applicant] = true unless active_affiliation[:detail] == 'Applied'
            result[:preSir] = true if active_affiliation[:detail] == 'Admitted'
          when 'GRADUATE'
            result[:student] = true
            result[:graduate] = true
          # TODO CalCentral does not yet source the instructional-staff role from CS.
          # when 'INSTRUCTOR'
          #   result[:faculty] = true
          when 'ADVISOR'
            result[:advisor] = true
          when 'STUDENT'
            result[:student] = true
          when 'UNDERGRAD'
            result[:student] = true
            result[:undergrad] = true
          when 'LAW'
            result[:law] = true
          when 'EXTENSION'
            result[:concurrentEnrollmentStudent] = true
        end
      end
      cs_affiliations.select { |a| a[:status][:code] == 'INA' }.each do |inactive_affiliation|
        if !result[:student] && %w(GRADUATE STUDENT UNDERGRAD).include?(inactive_affiliation[:type][:code])
          result[:exStudent] = true
        end
        if !result[:releasedAdmit] && inactive_affiliation[:type][:code] == 'APPLICANT' && inactive_affiliation[:type][:description] == 'Canceled'
          result[:withdrawnAdmit] = true
        end
      end
      base_roles.merge(result)
    end

    def find_matching_roles(ldap_groups, group_to_role)
      ldap_groups.inject({}) do |h, ldap_group|
        if (role = group_to_role[ldap_group])
          h.merge! role => true
        end
        h
      end
    end

    def ldap_student_affiliations_enabled
      Settings.features.ldap_student_affiliations
    end

  end
end
