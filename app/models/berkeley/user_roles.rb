module Berkeley
  module UserRoles
    extend self

    def roles_from_affiliations(affiliations)
      affiliations ||= []
      {
        :student => affiliations.index {|a| (a.start_with? 'STUDENT-TYPE-')}.present?,
        :registered => affiliations.include?('STUDENT-TYPE-REGISTERED'),
        :exStudent => affiliations.include?('STUDENT-STATUS-EXPIRED'),
        :faculty => affiliations.include?('EMPLOYEE-TYPE-ACADEMIC'),
        :staff => affiliations.include?('EMPLOYEE-TYPE-STAFF'),
        :guest => affiliations.include?('GUEST-TYPE-COLLABORATOR'),
        :concurrentEnrollmentStudent => affiliations.include?('AFFILIATE-TYPE-CONCURR ENROLL')
      }
    end

    def roles_from_ldap_affiliations(ldap_record)
      affiliations = ldap_record[:berkeleyeduaffiliations].to_a

      # Conflicting combinations of the following affiliations can be resolved by the corresponding
      # 'expdate' attribute. If the 'expdate' is in the past, then the expired '-STATUS-' affiliation
      # wins; if the 'expdate' is in the future or unset, then the active '-TYPE-' affiliation wins.
      {
        'STUDENT' => 'stu',
        'EMPLOYEE' => 'emp',
        'AFFILIATE' => 'aff',
        'GUEST' => 'aff'
      }.each do |aff_substring, expdate_substring|
        active_aff = affiliations.select {|aff| aff.start_with? "#{aff_substring}-TYPE-"}
        expired_aff = affiliations.select {|aff| aff.start_with? "#{aff_substring}-STATUS-"}
        if active_aff.present? && expired_aff.present?
          # During the SIS transition, we've been asked to skip the usual expiry date approach to
          # conflict resolution for the special case of STUDENT affiliations.
          if aff_substring == 'STUDENT'
            affiliations = affiliations - expired_aff
          else
            exp_date = ldap_record["berkeleyedu#{expdate_substring}expdate".to_sym].first
            if exp_date.blank? || DateTime.parse(exp_date) > DateTime.now
              affiliations = affiliations - expired_aff
            else
              affiliations = affiliations -  active_aff
            end
          end
        end
      end

      # TODO: CONFIRM: The combination of 'STUDENT-TYPE-NOT REGISTERED' and 'STUDENT-TYPE-REGISTERED' should be treated as registered.
      # (That's how Bear Facts seems to handle it, anyway.)

      roles_from_affiliations affiliations
    end

    def roles_from_ldap_groups(ldap_groups, expired_student)
      # TODO: Confirm that there is no CalGroup membership marker for 'STUDENT-TYPE-NOT REGISTERED'.
      # TODO: What is the difference between 'edu:berkeley:official:affiliates:concurrent' and 'edu:berkeley:official:students:concurrent'?
      return {} if ldap_groups.nil? || ldap_groups.empty?

      # Active-but-not-registered students have exactly the same list of memberships as registered students.
      group_prefix = 'cn=edu:berkeley:official:students'
      group_suffix = 'ou=campus groups,dc=berkeley,dc=edu'
      roles = find_matching_roles(ldap_groups, {
        "#{group_prefix}:all,#{group_suffix}" => :student,
        "#{group_prefix}:graduate,#{group_suffix}" => :graduate,
        "#{group_prefix}:undergrad,#{group_suffix}" => :undergrad
      })
      # We check for 'recentStudent' status if and only if (1) the more reliable LDAP affiliations tell us that this user
      # is an ex_student and (2) the user was not identified as an active student in the logic above.
      if expired_student && [:student, :undergrad, :graduate].none? { |s| roles[s] }
        roles.merge! find_matching_roles(ldap_groups, {
          "#{group_prefix}:students-grad-grace,#{group_suffix}" => :recentStudent,
          "#{group_prefix}:students-ug-grace,#{group_suffix}" => :recentStudent,
          "#{group_prefix}:summer-grace,#{group_suffix}" => :recentStudent
        })
      end
      roles
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
            result[:applicant] = true
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
        end
      end
      cs_affiliations.select { |a| a[:status][:code] == 'INA' }.each do |inactive_affiliation|
        if !result[:student] && %w(GRADUATE STUDENT UNDERGRAD).include?(inactive_affiliation[:type][:code])
          result[:exStudent] = true
        end
      end
      result
    end

    def find_matching_roles(ldap_groups, group_to_role)
      ldap_groups.inject({}) do |h, ldap_group|
        if (role = group_to_role[ldap_group])
          h.merge! role => true
        end
        h
      end
    end

  end
end
