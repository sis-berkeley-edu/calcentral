describe User::Api do
  let(:testee) { User::Api.new(uid) }
  let(:uid) { random_id }
  let(:original_delegate_user_id) { nil }
  let(:original_advisor_user_id) { nil }
  let(:can_administrate) { false }
  let(:can_view_as) { false }
  let(:directly_authenticated) { false }
  let(:authenticated_as_advisor) { false }
  let(:authenticated_as_delegate) { false }
  let(:delegated_privileges) { {} }
  let(:is_viewer) { false }
  let(:classic_viewing_as) { false }
  let(:has_advisor_role) { false }
  let(:has_student_role) { false }
  let(:has_staff_role) { false }
  let(:has_applicant_role) { false }
  let(:has_exstudent_role) { false }
  let(:has_faculty_role) { false }
  let(:roles) do
    {
      advisor: has_advisor_role,
      student: has_student_role,
      staff: has_staff_role,
      applicant: has_applicant_role,
      exStudent: has_exstudent_role,
      faculty: has_faculty_role
    }
  end
  let(:has_instructor_history) { false }
  let(:has_student_history) { false }
  let(:default_name) { 'Default Name' }
  let(:override_name) { nil }
  let(:first_name) { 'First' }
  let(:last_name) { 'Last' }
  let(:given_first_name) { 'Given' }
  let(:family_name) { 'Family' }
  let(:user_attributes) do
    {
      isLegacyStudent: false,
      sisProfileVisible: sis_profile_visible,
      roles: roles,
      defaultName: default_name,
      firstName: first_name,
      lastName: last_name,
      givenFirstName: given_first_name,
      familyName: family_name,
      studentId: '1234567890',
      campusSolutionsId: '1234567890',
      primaryEmailAddress: 'foo@foo.com',
      officialBmailAddress: 'foo@berkeley.edu',
      educationAbroad: false
    }
  end
  let(:sis_profile_visible) { false }
  let(:campus_solutions_id) { random_id }
  let(:privilege_view_grades) { false }
  let(:privilege_view_enrollments) { false }
  let(:privilege_financial) { false }
  let(:privilege_phone) { false }
  let(:delegate_students) do
    {
      feed: {
        students: [
          {
            campusSolutionsId: campus_solutions_id,
            uid: uid,
            privileges: {
              financial: privilege_financial,
              viewEnrollments: privilege_view_enrollments,
              viewGrades: privilege_view_grades,
              phone: privilege_phone
            }
          }
        ]
      }
    }
  end
  let(:is_calcentral) { true }
  let(:login_time) { DateTime.new(2017, 5, 26, 12, 6, 0) }

  before(:each) do
    configure_mocks
    testee.init
  end

  describe '#preferred_name' do
    subject { testee.preferred_name }

    it 'uses default name' do
      puts subject
      expect(subject).to eq default_name
    end
    context 'when override name exists' do
      let(:override_name) { 'Override Name' }
      it 'uses override name' do
        expect(subject).to eq override_name
      end
    end
    context 'when neither default nor override name exist' do
      let(:default_name) { nil }
      it 'returns an empty string' do
        expect(subject).to eq ''
      end
    end
  end

  describe '#update_attributes' do
    before(:each) do
      testee.update_attributes(attributes)
    end
    let(:attributes) { {preferred_name: new_name} }
    let(:new_name) { 'New Name' }

    it 'saves the preferred name' do
      expect(testee.preferred_name).to eq new_name
    end
    context 'when preferred name is not provided' do
      let(:attributes) { {unrelated: 'attribute'} }
      it 'saves without changing the preferred name' do
        expect(testee.preferred_name).to eq default_name
      end
    end
  end

  describe '#record_first_login' do
    before(:each) do
      allow(DateTime).to receive(:now).and_return login_time
      testee.record_first_login
    end

    it 'sets the login time' do
      expect(testee.first_login_at).to eq login_time
    end
  end

  describe '#get_delegate_students' do
    subject { testee.get_delegate_students }

    shared_context 'it doesn\'t find any students' do
      it 'returns nil' do
        expect(subject).to be nil
      end
    end

    context 'when user is not a delegate' do
      it_behaves_like 'it doesn\'t find any students'
    end
    context 'when user is a delegate' do
      let(:original_delegate_user_id) { random_id }
      it 'returns a list of students' do
        expect(subject).to eq delegate_students[:feed][:students]
      end
      context 'when delegate has no students' do
        let(:delegate_students) {}
        it_behaves_like 'it doesn\'t find any students'
      end
    end
    context 'when request is not coming from CalCentral' do
      let(:is_calcentral) { false }
      it_behaves_like 'it doesn\'t find any students'
    end
  end

  describe '#get_feed' do
    subject { testee.get_feed }
    let(:expected_acting_as_uid) { uid }
    let(:match_expected_advisor_acting_as_uid) { be_falsey }
    let(:expected_can_act_on_finances) { false }
    let(:expected_can_see_cs_links) { false }
    let(:expected_can_view_grades) { false }
    let(:match_expected_delegate_acting_as_uid) { be_falsey }
    let(:expected_first_login_at) { '2017-04-19T11:54:29.086-07:00' }
    let(:expected_first_name) { first_name }
    let(:expected_full_name) { first_name + ' ' + last_name }
    let(:expected_given_first_name) { given_first_name }
    let(:expected_given_full_name) { given_first_name + ' ' + family_name }
    let(:expected_can_view_academics) { false }
    let(:expected_has_badges) { false }
    let(:expected_has_campus_tab) { false }
    let(:expected_has_dashboard_tab) { false }
    let(:expected_has_financials_tab) { false }
    let(:expected_has_toolbox_tab) { false }
    let(:expected_is_delegate_user) { false }
    let(:expected_is_super_user) { false }
    let(:expected_is_viewer) { false }
    let(:expected_last_name) { last_name }
    let(:expected_preferred_name) { default_name }
    let(:expected_show_sis_profile_ui) { false }

    shared_examples 'a well-tempered feed' do
      it 'contains the expected data' do
        expect(subject[:actingAsUid]).to eq expected_acting_as_uid
        expect(subject[:advisorActingAsUid]).to match_expected_advisor_acting_as_uid
        expect(subject[:canActOnFinances]).to eq expected_can_act_on_finances
        expect(subject[:canSeeCSLinks]).to eq expected_can_see_cs_links
        expect(subject[:canViewGrades]).to eq expected_can_view_grades
        expect(subject[:delegateActingAsUid]).to match_expected_delegate_acting_as_uid
        expect(subject[:firstLoginAt]).to eq expected_first_login_at
        expect(subject[:firstName]).to eq expected_first_name
        expect(subject[:fullName]).to eq expected_full_name
        expect(subject[:givenFirstName]).to eq expected_given_first_name
        expect(subject[:givenFullName]).to eq expected_given_full_name
        expect(subject[:hasAcademicsTab]).to eq expected_can_view_academics
        expect(subject[:hasBadges]).to eq expected_has_badges
        expect(subject[:hasCampusTab]).to eq expected_has_campus_tab
        expect(subject[:hasDashboardTab]).to eq expected_has_dashboard_tab
        expect(subject[:hasFinancialsTab]).to eq expected_has_financials_tab
        expect(subject[:hasToolboxTab]).to eq expected_has_toolbox_tab
        expect(subject[:isDelegateUser]).to eq expected_is_delegate_user
        expect(subject[:isSuperuser]).to eq expected_is_super_user
        expect(subject[:isViewer]).to eq expected_is_viewer
        expect(subject[:lastName]).to eq expected_last_name
        expect(subject[:preferredName]).to eq expected_preferred_name
        expect(subject[:showSisProfileUI]).to eq expected_show_sis_profile_ui
      end
    end

    it_behaves_like 'a well-tempered feed'

    context 'when user is a delegate' do
      let(:directly_authenticated) { true }
      let(:original_delegate_user_id) { random_id }
      let(:expected_acting_as_uid) { false }
      let(:expected_can_act_on_finances) { true }
      let(:expected_can_see_cs_links) { true }
      let(:expected_is_delegate_user) { true }
      let(:expected_has_toolbox_tab) { true }
      it_behaves_like 'a well-tempered feed'

      context 'and show profile flag is true' do
        let(:sis_profile_visible) { true }
        let(:expected_show_sis_profile_ui) { false }
        it_behaves_like 'a well-tempered feed'
      end

      context 'and viewing as a student' do
        let(:authenticated_as_delegate) { true }
        let(:directly_authenticated) { false }
        let(:expected_can_act_on_finances) { false }
        let(:expected_can_see_cs_links) { false }
        let(:expected_has_toolbox_tab) { false }
        let(:match_expected_delegate_acting_as_uid) { eq original_delegate_user_id }
        let(:expected_first_name) { given_first_name }
        let(:expected_full_name) { expected_given_full_name }
        let(:expected_preferred_name) { expected_given_full_name }
        let(:expected_is_delegate_user) { false }
        let(:expected_first_login_at) { nil }
        let(:expected_acting_as_uid) { false }
        it_behaves_like 'a well-tempered feed'

        context 'and has privilege to see other users\' finances' do
          let(:delegated_privileges) { {financial: true} }
          let(:expected_can_act_on_finances) { true }
          let(:expected_has_financials_tab) { true }
          it_behaves_like 'a well-tempered feed'
        end

        context 'and has privilege to see other users\' grades' do
          let(:delegated_privileges) { {viewGrades: true} }
          let(:expected_can_view_academics) { true }
          let(:expected_can_view_grades) { true }
          it_behaves_like 'a well-tempered feed'
        end

        context 'and has privilege to see other users\' enrollments' do
          let(:delegated_privileges) { {viewEnrollments: true} }
          let(:expected_can_view_academics) { true }
          it_behaves_like 'a well-tempered feed'
        end
      end

      context 'and has no students assigned' do
        let(:delegate_students) { {} }
        let(:expected_is_delegate_user) { false }
        let(:expected_has_toolbox_tab) { false }
        it_behaves_like 'a well-tempered feed'
      end

      context 'and is also an advisor' do
        let(:has_advisor_role) { true }
        let(:expected_can_view_grades) { true }
        let(:expected_has_badges) { true }
        let(:expected_has_campus_tab) { true }
        let(:expected_has_dashboard_tab) { true }
        let(:expected_has_toolbox_tab) { true }
        it_behaves_like 'a well-tempered feed'
      end
    end

    context 'when user is an advisor' do
      let(:directly_authenticated) { true }
      let(:has_advisor_role) { true }
      let(:original_advisor_user_id) { random_id }
      let(:expected_acting_as_uid) { false }
      let(:expected_can_act_on_finances) { true }
      let(:expected_can_see_cs_links) { true }
      let(:expected_can_view_grades) { true }
      let(:expected_has_badges) { true }
      let(:expected_has_campus_tab) { true }
      let(:expected_has_dashboard_tab) { true }
      let(:expected_has_toolbox_tab) { true }
      it_behaves_like 'a well-tempered feed'

      context 'and show profile flag is true' do
        let(:sis_profile_visible) { true }
        let(:expected_show_sis_profile_ui) { true }
        it_behaves_like 'a well-tempered feed'
      end

      context 'and viewing as a student' do
        let(:authenticated_as_advisor) { true }
        let(:directly_authenticated) { false }
        let(:match_expected_advisor_acting_as_uid) { eq original_advisor_user_id }
        let(:expected_can_act_on_finances) { false }
        let(:expected_can_see_cs_links) { false }
        let(:expected_has_badges) { false }
        let(:expected_has_toolbox_tab) { false }
        it_behaves_like 'a well-tempered feed'

        context 'and show profile flag is true' do
          let(:sis_profile_visible) { true }
          let(:expected_show_sis_profile_ui) { true }
          it_behaves_like 'a well-tempered feed'
        end
      end
    end

    context 'when user is a superuser' do
      let(:can_administrate) { true }
      let(:expected_can_act_on_finances) { false }
      let(:expected_has_badges) { true }
      let(:expected_has_campus_tab) { true }
      let(:expected_has_dashboard_tab) { true }
      let(:expected_is_super_user) { true }
      it_behaves_like 'a well-tempered feed'

      context 'and show profile flag is true' do
        let(:sis_profile_visible) { true }
        let(:expected_show_sis_profile_ui) { true }
        it_behaves_like 'a well-tempered feed'
      end
    end

    context 'when user is a student' do
      let(:has_student_role) { true }
      let(:expected_can_view_academics) { true }
      let(:expected_can_view_grades) { true }
      let(:expected_has_badges) { true }
      let(:expected_has_campus_tab) { true }
      let(:expected_has_dashboard_tab) { true }
      let(:expected_has_financials_tab) { true }
      it_behaves_like 'a well-tempered feed'

      context 'and show profile flag is true' do
        let(:sis_profile_visible) { true }
        let(:expected_show_sis_profile_ui) { true }
        it_behaves_like 'a well-tempered feed'
      end
    end

    context 'when user is staff' do
      let(:has_staff_role) { true }
      let(:expected_has_badges) { true }
      let(:expected_has_campus_tab) { true }
      let(:expected_has_dashboard_tab) { true }
      it_behaves_like 'a well-tempered feed'

      context 'and has instructor history' do
        let(:has_instructor_history) { true }
        let(:expected_can_view_academics) { true }
        let(:expected_can_view_grades) { true }
        it_behaves_like 'a well-tempered feed'
      end

      context 'and has student history' do
        let(:has_student_history) { true }
        let(:expected_can_view_academics) { true }
        let(:expected_can_view_grades) { true }
        let(:expected_has_financials_tab) { true }
        it_behaves_like 'a well-tempered feed'
      end
    end

    context 'when user is an applicant' do
      let(:has_applicant_role) { true }
      let(:expected_can_view_academics) { true }
      let(:expected_can_view_grades) { true }
      let(:expected_has_badges) { true }
      let(:expected_has_campus_tab) { true }
      let(:expected_has_dashboard_tab) { true }
      let(:expected_has_financials_tab) { true }
      it_behaves_like 'a well-tempered feed'
    end

    context 'when user is an ex-student' do
      let(:has_exstudent_role) { true }
      let(:expected_has_financials_tab) { true }
      let(:expected_has_badges) { true }
      let(:expected_has_campus_tab) { true }
      let(:expected_has_dashboard_tab) { true }
      it_behaves_like 'a well-tempered feed'
    end

    context 'when user is faculty' do
      let(:has_faculty_role) { true }
      let(:expected_can_view_academics) { true }
      let(:expected_can_view_grades) { true }
      let(:expected_has_badges) { true }
      let(:expected_has_campus_tab) { true }
      let(:expected_has_dashboard_tab) { true }
      it_behaves_like 'a well-tempered feed'
    end

    context 'when user has view-as privilege' do
      let(:can_view_as) { true }
      let(:expected_is_viewer) { true }
      it_behaves_like 'a well-tempered feed'

      context 'and user is a delegate' do
        let(:directly_authenticated) { true }
        let(:original_delegate_user_id) { random_id }
        let(:expected_acting_as_uid) { false }
        let(:expected_can_act_on_finances) { true }
        let(:expected_can_see_cs_links) { true }
        let(:expected_has_toolbox_tab) { true }
        let(:expected_is_delegate_user) { true }
        let(:expected_is_viewer) { true }
        it_behaves_like 'a well-tempered feed'

        context 'viewing as a student' do
          let(:authenticated_as_delegate) { true }
          let(:directly_authenticated) { false }
          let(:expected_can_act_on_finances) { false }
          let(:match_expected_delegate_acting_as_uid) { eq original_delegate_user_id }
          let(:expected_can_see_cs_links) { false }
          let(:expected_first_name) { given_first_name }
          let(:expected_full_name) { expected_given_full_name }
          let(:expected_preferred_name) { expected_given_full_name }
          let(:expected_first_login_at) { nil }
          let(:expected_has_toolbox_tab) { false }
          let(:expected_is_delegate_user) { false }
          let(:expected_is_viewer) { false }
          it_behaves_like 'a well-tempered feed'
        end
      end
    end

    context 'when user has privilege to see other users\' finances' do
      let(:delegated_privileges) { {financial: true} }
      it_behaves_like 'a well-tempered feed'
    end

    context 'when user has privilege to see other users\' grades' do
      let(:delegated_privileges) { {viewGrades: true} }
      it_behaves_like 'a well-tempered feed'
    end

    context 'when user has privilege to see other users\' enrollments' do
      let(:delegated_privileges) { {viewEnrollments: true} }
      it_behaves_like 'a well-tempered feed'
    end

    context 'when show profile flag is true but user doesn\'t have the right role' do
      let(:sis_profile_visible) { true }
      let(:expected_show_sis_profile_ui) { false }
      it_behaves_like 'a well-tempered feed'
    end
  end
  def configure_mocks
    calcentral_user_data = double('User::Data record', :preferred_name => override_name, :first_login_at => '2017-04-19T11:54:29.086-07:00', :update_attribute => false)
    mock_user_model = double('User::Data model', :first => calcentral_user_data, :first_or_create => calcentral_user_data)
    allow(User::Data).to receive(:where).with(uid: uid).and_return mock_user_model

    allow(User::Oauth2Data).to receive(:get_google_email).with(uid).and_return ''
    allow(User::Oauth2Data).to receive(:is_google_reminder_dismissed).with(uid).and_return false

    allow(User::HasStudentHistory).to receive(:new).with(uid).and_return double(has_student_history?: has_student_history)
    allow(User::HasInstructorHistory).to receive(:new).with(uid).and_return double(has_instructor_history?: has_instructor_history)

    allow(GoogleApps::Proxy).to receive(:access_granted?).and_return false

    allow(User::AggregatedAttributes).to receive(:new).with(uid).and_return double(get_feed: user_attributes)

    allow(AuthenticationStatePolicy).to receive(:new).and_return double(can_administrate?: can_administrate, can_view_as?: can_view_as)
    allow(User::Auth).to receive(:get).with(uid).and_return double(active?: true, is_viewer?: is_viewer)
    allow(AuthenticationState).to receive(:new).with('user_id' => uid).and_return double(
                                                                                    original_delegate_user_id: original_delegate_user_id,
                                                                                    original_advisor_user_id: original_advisor_user_id,
                                                                                    directly_authenticated?: directly_authenticated,
                                                                                    authenticated_as_delegate?: authenticated_as_delegate,
                                                                                    authenticated_as_advisor?: authenticated_as_advisor,
                                                                                    delegated_privileges: delegated_privileges,
                                                                                    real_user_id: uid,
                                                                                    classic_viewing_as?: classic_viewing_as,
                                                                                    policy: AuthenticationStatePolicy.new(nil, nil),
                                                                                    user_auth: User::Auth.get(uid),
                                                                                    real_user_auth: User::Auth.get(uid)
                                                                                  )

    allow(CampusSolutions::DelegateStudents).to receive(:new).with(user_id: uid).and_return double(get: {})
    allow(CampusSolutions::DelegateStudents).to receive(:new).with(user_id: original_delegate_user_id).and_return double(get: delegate_students)

    allow(ProvidedServices).to receive(:calcentral?).and_return is_calcentral
  end
end
