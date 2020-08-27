module HubEdos
  class UserAttributes
    include User::Identifiers
    include ResponseWrapper
    include ClassLogger

    def initialize(options = {})
      @uid = options[:user_id]
    end

    def self.test_data?
      Settings.hub_person_proxy.fake.present? && Settings.hub_edos_proxy.fake.present?
    end

    def get_ids(result)
      result[:ldap_uid] = @uid
      result[:campus_solutions_id] = campus_solutions_id
    end

    def campus_solutions_id
      # Hub and CampusSolutions APIs will be unreachable unless a CS ID is provided from Crosswalk or SAML assertions.
      @campus_solutions_id ||= lookup_campus_solutions_id
    end

    def get_sis_person
      @sis_person ||= begin
        person = HubEdos::PersonApi::V1::SisPerson.new(user_id: @uid).get
        HashConverter.symbolize(person.try(:[], :feed))
      end
    end

    def get_student_attributes
      @student_attributes ||= begin
        student_attributes = HubEdos::StudentApi::V2::Feeds::StudentAttributes.new(user_id: @uid).get
        if student_attributes[:studentNotFound]
          logger.warn "Student Attributes request failed for UID #{@uid}"
          return {}
        end
        HashConverter.symbolize(student_attributes.try(:[], :feed))
      end
    end

    def get
      wrapped_result = handling_exceptions(@uid) do
        result = {}
        get_ids result
        if campus_solutions_id.present? && (person_feed = get_sis_person)
          identifiers_check person_feed
          extract_roles(person_feed, result)
          extract_names(person_feed, result)
          extract_emails(person_feed, result)
          result[:statusCode] = 200
        else
          logger.warn "Could not get SIS Person data for UID #{@uid}"
          result[:noStudentId] = true
        end
        result
      end
      wrapped_result[:response]
    end

    def has_role?(*roles)
      if lookup_campus_solutions_id.present? && (person_feed = get_sis_person)
        result = {}
        extract_roles(person_feed, result)
        if (user_role_map = result[:roles])
          roles.each do |role|
            return true if user_role_map[role]
          end
        end
      end
      false
    end

    def identifiers_check(person_feed)
      # CS Identifiers simply treat 'student-id' as a synonym for the Campus Solutions ID / EmplID, regardless
      # of whether the user has ever been a student. (In contrast, CalNet LDAP's 'berkeleyedustuid' attribute
      # only appears for current or former students.)
      identifiers = person_feed[:identifiers]
      if identifiers.blank?
        logger.error "No 'identifiers' found in CS attributes #{person_feed} for UID #{@uid}, CS ID #{campus_solutions_id}"
      else
        student_id = identifiers.select {|id| id[:type] == 'student-id'}.first
        if student_id.blank?
          logger.error "No 'student-id' found in CS Identifiers #{identifiers} for UID #{@uid}, CS ID #{campus_solutions_id}"
          return false
        elsif student_id[:id] != campus_solutions_id
          logger.error "Got student-id #{student_id[:id]} from CS Identifiers but CS ID #{campus_solutions_id} from Crosswalk for UID #{@uid}"
        end
      end
    end

    def extract_names(edo, result)
      # preferred name trumps primary name if present
      find_name('PRI', edo, result) unless find_name('PRF', edo, result)
    end

    def find_name(type, edo, result)
      found_match = false
      if edo[:names].present?
        edo[:names].each do |name|
          if name[:type].present? && name[:type][:code].present?
            if name[:type][:code].upcase == 'PRI'
              result[:given_name] = name[:givenName]
              result[:family_name] = name[:familyName]
            end
            if name[:type].present? && name[:type][:code].present? && name[:type][:code].upcase == type.upcase
              result[:first_name] = name[:givenName]
              result[:last_name] = name[:familyName]
              result[:person_name] = name[:formattedName]
              found_match = true
            end
          end
        end
      end
      found_match
    end

    def extract_roles(person_feed, result)
      # CS Affiliations are expected to exist for any working CS ID.
      if (affiliations = person_feed[:affiliations])
        result[:roles] = Berkeley::UserRoles.roles_from_cs_affiliations(affiliations)
        if result[:roles].slice(:student, :exStudent, :applicant, :releasedAdmit).has_value?(true)
          result[:student_id] = campus_solutions_id
          student_attributes = get_student_attributes
          result[:roles][:confidential] = true if student_attributes[:confidential]
        end
      else
        logger.error "No 'affiliations' found in CS attributes #{person_feed} for UID #{@uid}, CS ID #{campus_solutions_id}"
      end
    end

    def extract_emails(edo, result)
      if edo[:emails].present?
        edo[:emails].each do |email|
          if email[:primary] == true
            result[:email_address] = email[:emailAddress]
          end
          if email[:type].present? && email[:type][:code] == 'CAMP'
            result[:official_bmail_address] = email[:emailAddress]
          end
        end
      end
    end

  end
end
