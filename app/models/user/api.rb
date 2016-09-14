module User
  class Api < UserSpecificModel
    include ActiveRecordHelper
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    # Needed to expire cache entries specific to Viewing-As users alongside original user's cache.
    include Cache::RelatedCacheKeyTracker
    include CampusSolutions::DelegatedAccessFeatureFlagged
    include ClassLogger

    def init
      use_pooled_connection {
        @calcentral_user_data ||= User::Data.where(:uid => @uid).first
      }
      @user_attributes ||= User::AggregatedAttributes.new(@uid, @options).get_feed
      @first_login_at ||= @calcentral_user_data ? @calcentral_user_data.first_login_at : nil
      @override_name ||= @calcentral_user_data ? @calcentral_user_data.preferred_name : nil
      @delegate_students = get_delegate_students
      self
    end

    def instance_key
      Cache::KeyGenerator.per_view_as_type @uid, @options
    end

    def get_delegate_students
      return nil unless is_cs_delegated_access_feature_enabled
      delegate_uid = authentication_state.original_delegate_user_id || @uid
      response = CampusSolutions::DelegateStudents.new(user_id: delegate_uid).get
      response && response[:feed] && response[:feed][:students]
    end

    def preferred_name
      @override_name || @user_attributes[:defaultName] || ''
    end

    def preferred_name=(val)
      if val.blank?
        val = nil
      else
        val.strip!
      end
      @override_name = val
    end

    def self.delete(uid)
      logger.warn "Removing all stored user data for user #{uid}"
      user = nil
      use_pooled_connection {
        Calendar::User.delete_all({uid: uid})
        user = User::Data.where(:uid => uid).first
        if !user.blank?
          user.delete
        end
      }
      if !user.blank?
        GoogleApps::Revoke.new(user_id: uid).revoke
        use_pooled_connection {
          User::Oauth2Data.destroy_all(:uid => uid)
          Notifications::Notification.destroy_all(:uid => uid)
        }
      end

      Cache::UserCacheExpiry.notify uid
    end

    def save
      use_pooled_connection {
        Retriable.retriable(:on => ActiveRecord::RecordNotUnique, :tries => 5) do
          @calcentral_user_data = User::Data.where(uid: @uid).first_or_create do |record|
            logger.debug "Recording first login for #{@uid}"
            record.preferred_name = @override_name
            record.first_login_at = @first_login_at
          end
          if @calcentral_user_data.preferred_name != @override_name
            @calcentral_user_data.update_attribute(:preferred_name, @override_name)
          end
        end
      }
      Cache::UserCacheExpiry.notify @uid
    end

    def update_attributes(attributes)
      init
      if attributes.has_key?(:preferred_name)
        self.preferred_name = attributes[:preferred_name]
      end
      save
    end

    def record_first_login
      init
      @first_login_at = DateTime.now
      save
    end

    def is_delegate_user?
      authentication_state.directly_authenticated? && !@delegate_students.nil? && @delegate_students.any?
    end

    def has_academics_tab?(roles, has_instructor_history, has_student_history)
      roles[:student] || roles[:faculty] || roles[:applicant] || has_instructor_history || has_student_history
    end

    def has_financials_tab?(roles)
      !!(roles[:student] || roles[:exStudent] || roles[:applicant])
    end

    def has_toolbox_tab?(policy, roles)
      return false unless authentication_state.directly_authenticated? && authentication_state.user_auth.active?
      policy.can_administrate? || authentication_state.real_user_auth.is_viewer? || is_delegate_user? || !!roles[:advisor]
    end

    def filter_user_api_for_delegator(feed)
      view_as_privileges = authentication_state.delegated_privileges
      feed[:delegateViewAsPrivileges] = view_as_privileges
      # Delegate users get a pared-down UX.
      feed[:hasDashboardTab] = false
      feed[:showSisProfileUI] = false
      # Delegate users do not have access to preferred name and similar sensitive data.
      feed[:firstName] = feed[:givenFirstName]
      feed[:fullName] = feed[:givenFullName]
      feed[:preferredName] = feed[:givenFullName]
      feed.delete :firstLoginAt
      # Extraordinary privileges are set to false.
      feed[:isDelegateUser] = false
      feed[:isViewer] = false
      feed[:isSuperuser] = false
      # Filter based on delegation rights chosen by the student.
      feed[:canViewGrades] = false unless view_as_privileges[:viewGrades]
      feed[:hasFinancialsTab] = false unless view_as_privileges[:financial]
      feed[:hasAcademicsTab] = false unless view_as_privileges[:viewEnrollments] || view_as_privileges[:viewGrades]
      feed[:canActOnFinances] = !!view_as_privileges[:financial]
      feed
    end

    def get_feed_internal
      given_first_name = @user_attributes[:givenFirstName]
      first_name = @user_attributes[:firstName]
      last_name = @user_attributes[:lastName]
      google_mail = User::Oauth2Data.get_google_email @uid
      current_user_policy = authentication_state.policy
      is_google_reminder_dismissed = User::Oauth2Data.is_google_reminder_dismissed(@uid)
      is_google_reminder_dismissed = is_google_reminder_dismissed && is_google_reminder_dismissed.present?
      is_calendar_opted_in = Calendar::User.where(:uid => @uid).first.present?
      has_student_history = User::HasStudentHistory.new(@uid).has_student_history?
      has_instructor_history = User::HasInstructorHistory.new(@uid).has_instructor_history?
      roles = @user_attributes[:roles]
      logger.error "UID #{@uid} has active student role but no CS ID" if @user_attributes[:campusSolutionsId].blank? && roles[:student] && !Berkeley::Terms.fetch.current.legacy?
      can_view_academics = has_academics_tab?(roles, has_instructor_history, has_student_history)
      directly_authenticated = authentication_state.directly_authenticated?
      # This tangled logic is a historical artifact of divergent approaches to View-As and LTI-based authentication.
      acting_as_uid = directly_authenticated || authentication_state.authenticated_as_delegate? || authentication_state.authenticated_as_advisor? ?
        false : authentication_state.real_user_id
      feed = {
        isSuperuser: current_user_policy.can_administrate?,
        isViewer: current_user_policy.can_view_as?,
        firstLoginAt: @first_login_at,
        firstName: first_name,
        lastName: last_name,
        fullName: first_name + ' ' + last_name,
        givenFirstName: given_first_name,
        givenFullName: given_first_name + ' ' + @user_attributes[:familyName],
        isGoogleReminderDismissed: is_google_reminder_dismissed,
        isCalendarOptedIn: is_calendar_opted_in,
        hasGoogleAccessToken: GoogleApps::Proxy.access_granted?(@uid),
        hasStudentHistory: has_student_history,
        hasInstructorHistory: has_instructor_history,
        hasDashboardTab: true,
        hasAcademicsTab: can_view_academics,
        canViewGrades: can_view_academics || !!roles[:advisor],
        hasFinancialsTab: has_financials_tab?(roles),
        hasToolboxTab: has_toolbox_tab?(current_user_policy, roles),
        inEducationAbroadProgram: @user_attributes[:educationAbroad],
        googleEmail: google_mail,
        officialBmailAddress: @user_attributes[:officialBmailAddress],
        primaryEmailAddress: @user_attributes[:primaryEmailAddress],
        preferredName: self.preferred_name,
        roles: roles,
        uid: @uid,
        sid: @user_attributes[:studentId],
        campusSolutionsID: @user_attributes[:campusSolutionsId],
        isLegacyStudent: @user_attributes[:isLegacyStudent],
        isDelegateUser: is_delegate_user?,
        showSisProfileUI: @user_attributes[:sisProfileVisible],
        isDirectlyAuthenticated: directly_authenticated,
        actingAsUid: acting_as_uid,
        advisorActingAsUid: !directly_authenticated && authentication_state.original_advisor_user_id,
        delegateActingAsUid: !directly_authenticated && authentication_state.original_delegate_user_id,
        canSeeCSLinks: directly_authenticated || authentication_state.classic_viewing_as?,
        canActOnFinances: directly_authenticated
      }
      filter_user_api_for_delegator(feed) if authentication_state.authenticated_as_delegate?
      feed
    end

  end
end
