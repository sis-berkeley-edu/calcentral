module User
  class UserAttributes
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def summary
      {
        ldapUid: user.uid,
        unknown: unknown,
        sisProfileVisible: Settings.features.cs_profile,
        roles: user.roles,
        defaultName: get_campus_attribute('person_name', :string),
        firstName: first_name,
        lastName: last_name,
        givenFirstName: (@edo_attributes && @edo_attributes[:given_name]) || first_name || '',
        familyName: (@edo_attributes && @edo_attributes[:family_name]) || last_name || '',
        studentId: get_campus_attribute('student_id', :numeric_string),
        campusSolutionsId: campus_solutions_id,
        primaryEmailAddress: get_campus_attribute('email_address', :string),
        officialBmailAddress: get_campus_attribute('official_bmail_address', :string),
      }
    end

    def unknown?
      ldap_attributes_feed.blank? && campus_solutions_id.blank?
    end

    def campus_solutions_id
      edo_attributes_feed[:campus_solutions_id]
    end

    def edo_attributes
      return {} unless Settings.features.cs_profile
      @edo_attributes ||= HubEdos::UserAttributes.new(user_id: user.uid).get
    end

    def ldap_attributes
      @ldap_attributes ||= CalnetLdap::UserAttributes.new(user_id: user.uid).get_feed
    end

    def sis_profile_visible?
      Settings.features.cs_profile
    end
  end
end
