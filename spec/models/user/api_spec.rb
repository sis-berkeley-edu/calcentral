describe User::Api do
  let(:uid) { random_id }
  let(:original_delegate_user_id) { nil }
  let(:preferred_name) { 'Sid Vicious' }
  let(:edo_roles) do
    {
      student: true,
      exStudent: false,
      faculty: false,
      staff: false
    }
  end
  let(:edo_attributes) do
    {
      person_name: preferred_name,
      student_id: '1234567890',
      campus_solutions_id: 'CC12345678',
      is_legacy_user: false,
      official_bmail_address: 'foo@foo.com',
      roles: edo_roles
    }
  end
  let(:ldap_attributes) { {} }

  before(:each) do
    allow(HubEdos::UserAttributes).to receive(:new).with(user_id: uid).and_return double(get: edo_attributes)
    allow(CalnetLdap::UserAttributes).to receive(:new).with(user_id: uid).and_return double(get_feed: ldap_attributes)
    delegate_uid = original_delegate_user_id || uid
    allow(CampusSolutions::DelegateStudents).to receive(:new).with(user_id: delegate_uid).and_return double(get: delegate_students)
    unless CampusOracle::Queries.test_data?
      # Protect against random UID matches in testext Oracle DB.
      allow(CampusOracle::UserAttributes).to receive(:new).with(user_id: uid).and_return double(get_feed: {})
    end
  end

  context 'user attributes' do
    let(:delegate_students) { {} }
    it 'should find user with default name' do
      u = User::Api.new uid
      u.init
      expect(u.preferred_name).to eq preferred_name
    end
    it 'should override the default name' do
      u = User::Api.new uid
      u.update_attributes preferred_name: 'Herr Heyer'
      u = User::Api.new uid
      u.init
      expect(u.preferred_name).to eq 'Herr Heyer'
    end
    it 'should revert to the default name' do
      u = User::Api.new uid
      u.update_attributes preferred_name: 'Herr Heyer'
      u = User::Api.new uid
      u.update_attributes preferred_name: ''
      u = User::Api.new uid
      u.init
      expect(u.preferred_name).to eq preferred_name
    end
    it 'should return a user data structure' do
      api = User::Api.new(uid).get_feed
      expect(api[:preferredName]).to eq preferred_name
      expect(api[:isCalendarOptedIn]).to_not be_nil
      expect(api[:isCampusSolutionsStudent]).to be true
      expect(api[:isDelegateUser]).to be false
      expect(api[:showSisProfileUI]).to be true
      expect(api[:hasAcademicsTab]).to be true
      expect(api[:canViewGrades]).to be true
      expect(api[:hasToolboxTab]).to be false
      expect(api[:officialBmailAddress]).to eq 'foo@foo.com'
      expect(api[:campusSolutionsID]).to eq 'CC12345678'
      expect(api[:sid]).to eq '1234567890'
      expect(api[:delegateViewAsPrivileges]).to be_nil
      expect(api[:isDirectlyAuthenticated]).to be true
      expect(api[:canActOnFinances]).to be true
    end
    context 'advisor user' do
      let(:edo_roles) do
        {student: false, exStudent: false, faculty: false, advisor: true}
      end
      it 'allows viewing grades' do
        api = User::Api.new(uid).get_feed
        expect(api[:canViewGrades]).to be true
      end
    end
  end

  context 'delegate user' do
    let(:delegate_students) { {} }
    let(:api) {
      session = {
        'user_id' => uid,
        SessionKey.original_delegate_user_id => original_delegate_user_id
      }
      User::Api.from_session(session).get_feed
    }
    before do
      allow(Cal1card::Photo).to receive(:new).and_call_original
      allow(Cal1card::Photo).to receive(:new).with(uid).and_return double(get_feed: {})
    end
    context 'has no students' do
      context 'never nominated as delegate' do
        let(:response) { nil }
        it 'delegate has student with only phone privilege' do
          expect(api[:isDelegateUser]).to be false
          expect(api[:hasToolboxTab]).to be false
          expect(api[:delegateViewAsPrivileges]).to be_nil
        end
      end
      context 'once had students and now has none' do
        let(:response) { { feed: { students: [] } } }
        it 'delegate has student with only phone privilege' do
          expect(api[:isDelegateUser]).to be false
          expect(api[:hasToolboxTab]).to be false
          expect(api[:delegateViewAsPrivileges]).to be_nil
        end
      end
    end
    context 'has students' do
      let(:campus_solutions_id) { random_id }
      let(:privilege_financial) { false }
      let(:privilege_view_enrollments) { false }
      let(:privilege_view_grades) { false }
      let(:privilege_phone) { false }
      let(:delegate_students) {
        {
          feed: {
            students: [
              {
                campusSolutionsId: campus_solutions_id,
                uid: random_id,
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
      }
      context 'before view-as session' do
        it 'shows toolbox' do
          expect(api[:isDelegateUser]).to be true
          expect(api[:hasToolboxTab]).to be true
          expect(api[:delegateViewAsPrivileges]).to be_nil
          expect(api[:hasPhoto]).to be false
          expect(api[:isDirectlyAuthenticated]).to be true
          expect(api[:canActOnFinances]).to be true
        end
      end
      context 'view-as session' do
        let(:original_delegate_user_id) { random_id }
        let(:ldap_attributes) { {roles: {student: true}} }
        before {
          proxy = double lookup_campus_solutions_id: campus_solutions_id
          expect(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: uid).once.and_return proxy
        }
        context 'tabs per privileges' do
          let(:privilege_view_grades) { true }
          it 'should show My Academics tab' do
            expect(api[:hasDashboardTab]).to be false
            expect(api[:isDelegateUser]).to be false
            expect(api[:hasToolboxTab]).to be false
            expect(api[:hasAcademicsTab]).to be true
            expect(api[:canViewGrades]).to be true
            expect(api[:hasFinancialsTab]).to be false
            expect(api[:showSisProfileUI]).to be false
            privileges = api[:delegateViewAsPrivileges]
            expect(privileges).to be_a Hash
            expect(privileges).to include financial: false, viewEnrollments: false, viewGrades: true, phone: false
            expect(api[:hasPhoto]).to be false
            expect(api[:isDirectlyAuthenticated]).to be false
            expect(api[:canActOnFinances]).to be false
          end
        end
        context 'tabs per privileges' do
          let(:privilege_view_enrollments) { true }
          it 'should show My Academics tab and hide grades' do
            expect(api[:hasAcademicsTab]).to be true
            expect(api[:canViewGrades]).to be false
            expect(api[:hasPhoto]).to be false
            expect(api[:isDirectlyAuthenticated]).to be false
            expect(api[:canActOnFinances]).to be false
          end
        end
        context 'tabs per privileges' do
          let(:privilege_financial) { true }
          it 'should show My Finances tab' do
            expect(api[:hasAcademicsTab]).to be false
            expect(api[:canViewGrades]).to be false
            expect(api[:hasFinancialsTab]).to be true
            expect(api[:delegateViewAsPrivileges]).to include financial: true, viewEnrollments: false, viewGrades: false, phone: false
            expect(api[:hasPhoto]).to be false
            expect(api[:isDirectlyAuthenticated]).to be false
            expect(api[:canActOnFinances]).to be true
          end
        end
      end
    end
  end

  context 'with a legacy student' do
    let(:delegate_students) { {} }
    let(:api) { User::Api.new(uid).get_feed }
    let(:edo_attributes) do
      {
        person_name: preferred_name,
        campus_solutions_id: '12345678', # 8-digit ID means legacy
        is_legacy_user: true,
        roles: {
          student: true,
          exStudent: false,
          faculty: false,
          staff: false
        }
      }
    end
    context 'with the fallback enabled' do
      before do
        allow(Settings.features).to receive(:cs_profile_visible_for_legacy_users).and_return false
      end
      it 'should hide SIS profile for legacy students' do
        expect(api[:isCampusSolutionsStudent]).to be false
        expect(api[:showSisProfileUI]).to be false
      end
    end
    context 'with the fallback disabled' do
      before do
        allow(Settings.features).to receive(:cs_profile_visible_for_legacy_users).and_return true
      end
      it 'should show SIS profile for legacy students' do
        expect(api[:isCampusSolutionsStudent]).to be false
        expect(api[:showSisProfileUI]).to be true
      end
    end
  end

  context 'session metadata' do
    let(:delegate_students) { {} }
    it 'should have a null first_login time for a new user' do
      api = User::Api.new(uid).get_feed
      expect(api[:firstLoginAt]).to be_nil
    end
    it 'should properly register a call to record_first_login' do
      user_api = User::Api.new uid
      user_api.get_feed
      user_api.record_first_login
      updated_data = user_api.get_feed
      expect(updated_data[:firstLoginAt]).to_not be_nil
    end
    it 'should delete a user and all his dependent parts' do
      user_api = User::Api.new uid
      user_api.record_first_login
      user_api.get_feed

      expect(User::Oauth2Data).to receive :destroy_all
      expect(Notifications::Notification).to receive :destroy_all
      expect(Cache::UserCacheExpiry).to receive :notify
      expect(Calendar::User).to receive :delete_all

      User::Api.delete uid

      expect(User::Data.where :uid => uid).to eq []
    end

    it 'should say random student gets the academics tab' do
      api = User::Api.new(uid).get_feed
      expect(api[:hasAcademicsTab]).to be true
    end

    context 'a staff member with no academic history' do
      let(:edo_attributes) do
        {
          person_name: preferred_name,
          roles: {}
        }
      end
      let(:ldap_attributes) do
        {
          person_name: preferred_name,
          roles: {
            student: false,
            faculty: false,
            staff: true
          }
        }
      end
      before do
        allow(User::HasInstructorHistory).to receive(:new).and_return double(has_instructor_history?: false)
        allow(User::HasStudentHistory).to receive(:new).and_return double(has_student_history?: false)
      end
      it 'should deny academics tab' do
        api = User::Api.new(uid).get_feed
        expect(api[:hasAcademicsTab]).to eq false
        expect(api[:canViewGrades]).to be false
      end
    end
  end

  describe 'profile source of record' do
    let(:delegate_students) { {} }
    subject { User::Api.new(uid).get_feed }
    let(:ldap_attributes) do
      {
        official_bmail_address: 'bar@bar.edu',
        roles: {
          student: is_active_student,
          exStudent: !is_active_student,
          faculty: false,
          staff: true
        }
      }
    end
    context 'active student' do
      let(:is_active_student) { true }
      it 'relies on CS data' do
        expect(subject[:officialBmailAddress]).to eq 'foo@foo.com'
      end
    end
    context 'former student' do
      let(:is_active_student) { false }
      it 'relies on LDAP and Oracle' do
        expect(subject[:officialBmailAddress]).to eq 'bar@bar.edu'
      end
    end
    context 'applicant' do
      let(:edo_attributes) do
        {
          person_name: preferred_name,
          student_id: '1234567890',
          campus_solutions_id: 'CC12345678',
          official_bmail_address: 'foo@foo.com',
          roles: {
            student: false,
            exStudent: false,
            faculty: false,
            staff: true,
            applicant: true
          }
        }
      end
      let(:is_active_student) { false }
      it 'relies on CS data' do
        expect(subject[:officialBmailAddress]).to eq 'foo@foo.com'
      end
    end
    context 'broken Hub API' do
      let(:is_active_student) { true }
      let(:edo_attributes) do
        {
          body: 'An unknown server error occurred',
          statusCode: 503
        }
      end
      it 'relies on LDAP and Oracle' do
        expect(subject[:officialBmailAddress]).to eq 'bar@bar.edu'
      end
    end
  end

  describe 'My Finances tab' do
    let(:delegate_students) { {} }
    subject { User::Api.new(uid).get_feed[:hasFinancialsTab] }
    context 'active student' do
      let(:ldap_attributes) { {roles: { :student => true, :exStudent => false, :faculty => false, :staff => false }} }
      let(:edo_attributes) { {roles: { student: true } } }
      it { should be true }
    end
    context 'applicant' do
      let(:ldap_attributes) { {roles: { :student => false, :exStudent => false, :faculty => false, :staff => false }} }
      let(:edo_attributes) { {roles: { applicant: true } } }
      it { should be true }
    end
    context 'staff' do
      let(:ldap_attributes) { {roles: { :student => false, :exStudent => false, :faculty => false, :staff => true }} }
      let(:edo_attributes) { {roles: {}} }
      it { should be false }
    end
    context 'former student' do
      let(:ldap_attributes) { {roles: { :student => false, :exStudent => true, :faculty => false, :staff => false }} }
      let(:edo_attributes) { {roles: {}} }
      it { should be true }
    end
  end

  describe 'My Toolbox tab' do
    let(:delegate_students) { {} }
    context 'superuser' do
      before { User::Auth.new_or_update_superuser! uid }
      it 'should show My Toolbox tab' do
        user_api = User::Api.new uid
        expect(user_api.get_feed[:hasToolboxTab]).to be true
      end
    end
    context 'can_view_as' do
      before {
        user = User::Auth.new uid: uid
        user.is_viewer = true
        user.active = true
        user.save
      }
      subject { User::Api.new(uid).get_feed[:hasToolboxTab] }
      it { should be true }
    end
    context 'ordinary profiles' do
      let(:profiles) do
        {
          :student   => { :student => true,  :exStudent => false, :faculty => false, :advisor => false, :staff => false },
          :faculty   => { :student => false, :exStudent => false, :faculty => true,  :advisor => false, :staff => false },
          :advisor   => { :student => false, :exStudent => false, :faculty => true,  :advisor => true,  :staff => true },
          :staff     => { :student => false, :exStudent => false, :faculty => true,  :advisor => false, :staff => true }
        }
      end
      let(:ldap_attributes) { {roles: user_roles} }
      subject { User::Api.new(uid).get_feed[:hasToolboxTab] }
      context 'student' do
        let(:user_roles) { profiles[:student] }
        it { should be false }
      end
      context 'faculty' do
        let(:user_roles) { profiles[:faculty] }
        it { should be false }
      end
      context 'advisor' do
        let(:user_roles) { profiles[:advisor] }
        it { should be true }
      end
      context 'staff' do
        let(:user_roles) { profiles[:staff] }
        it { should be false }
      end
    end
  end

  context 'HubEdos errors', if: CampusOracle::Queries.test_data? do
    let(:uid) { '1151855' }
    let(:feed) { User::Api.new(uid).get_feed }
    let(:delegate_students) { {} }
    let(:expected_values_from_campus_oracle) {
      {
        preferredName: 'Eugene V Debs',
        firstName: 'Eugene V',
        lastName: 'Debs',
        fullName: 'Eugene V Debs',
        givenFirstName: 'Eugene V',
        givenFullName: 'Eugene V Debs',
        uid: uid,
        sid: '18551926',
        isCampusSolutionsStudent: false,
        roles: {
          student: true,
          registered: true,
          exStudent: false,
          faculty: false,
          staff: false,
          guest: false,
          concurrentEnrollmentStudent: false,
          expiredAccount: false
        }
      }
    }
    let(:expected_values_from_ldap) {
      {
        preferredName: 'Offissa Pupp',
        firstName: 'Offissa',
        lastName: 'Pupp',
        fullName: 'Offissa Pupp',
        givenFirstName: 'Offissa',
        givenFullName: 'Offissa Pupp',
        uid: uid,
        sid: '17154428',
        isCampusSolutionsStudent: false,
        roles: {
          student: false,
          registered: false,
          exStudent: true,
          faculty: true,
          staff: false,
          guest: false,
          concurrentEnrollmentStudent: false,
          expiredAccount: false
        }
      }
    }

    shared_examples 'handling bad behavior' do
      context 'LDAP attributes found' do
        let(:ldap_attributes) do
          {
            first_name: 'Offissa',
            last_name: 'Pupp',
            ldap_uid: uid,
            person_name: 'Offissa Pupp',
            roles: {
              student: false,
              registered: false,
              exStudent: true,
              faculty: true,
              staff: false,
              guest: false,
              concurrentEnrollmentStudent: false
            },
            student_id: '17154428'
          }
        end
        it 'should trust LDAP' do
          expect(feed).to include expected_values_from_ldap
        end
      end
      context 'LDAP attributes not found' do
        let(:ldap_attributes) { {roles: {}} }
        it 'should fall back to campus Oracle' do
          expect(feed).to include expected_values_from_campus_oracle
        end
      end
    end

    context 'empty response' do
      let(:edo_attributes) { {} }
      include_examples 'handling bad behavior'
    end

    context 'ID lookup errors' do
      let(:edo_attributes) do
        {
          student_id: {
            body: 'An unknown server error occurred',
            statusCode: 503
          }
        }
      end
      include_examples 'handling bad behavior'
    end

    context 'name lookup errors' do
      let(:edo_attributes) do
        {
          first_name: nil,
          last_name: nil,
          person_name: {
            body: 'An unknown server error occurred',
            statusCode: 503
          }
        }
      end
      include_examples 'handling bad behavior'
    end

    context 'role lookup errors' do
      let(:edo_attributes) do
        {
          roles: {}
        }
      end
      include_examples 'handling bad behavior'
    end

    context 'when ex-student is incorrectly reported active' do
      let(:uid) { '2040' }
      let(:edo_attributes) do
        {
          roles: {
            student: true
          }
        }
      end
      it 'should give precedence to campus Oracle on ex-student status' do
        expect(feed[:roles][:exStudent]).to eq true
        expect(feed[:roles][:student]).to eq false
      end
    end
  end

  context 'permissions' do
    let(:delegate_students) { {} }
    context 'proper cache handling' do
      it 'should update the last modified hash when content changes' do
        user_api = User::Api.new uid
        user_api.get_feed
        original_last_modified = User::Api.get_last_modified uid
        old_hash = original_last_modified[:hash]
        old_timestamp = original_last_modified[:timestamp]

        sleep 1

        user_api.preferred_name = 'New Name'
        user_api.save
        feed = user_api.get_feed
        new_last_modified = User::Api.get_last_modified uid
        expect(new_last_modified[:hash]).to_not eq old_hash
        expect(new_last_modified[:timestamp]).to_not eq old_timestamp
        expect(new_last_modified[:timestamp][:epoch]).to eq feed[:lastModified][:timestamp][:epoch]
      end

      it 'should not update the last modified hash when content has not changed' do
        user_api = User::Api.new uid
        user_api.get_feed
        original_last_modified = User::Api.get_last_modified uid

        sleep 1

        Cache::UserCacheExpiry.notify uid
        feed = user_api.get_feed
        unchanged_last_modified = User::Api.get_last_modified uid
        expect(original_last_modified).to eq unchanged_last_modified
        expect(original_last_modified[:timestamp][:epoch]).to eq feed[:lastModified][:timestamp][:epoch]
      end
    end
    context 'proper handling of superuser permissions' do
      before { User::Auth.new_or_update_superuser! uid }
      subject { User::Api.new(uid).get_feed }
      it 'should pass the superuser status' do
        expect(subject[:isSuperuser]).to be true
        expect(subject[:isViewer]).to be true
        expect(subject[:hasToolboxTab]).to be true
        expect(subject[:hasAcademicsTab]).to be true
        expect(subject[:canViewGrades]).to be true
      end
    end
    context 'proper handling of viewer permissions' do
      before {
        user = User::Auth.new uid: uid
        user.is_viewer = true
        user.active = true
        user.save
      }
      subject { User::Api.new(uid).get_feed }
      it 'should pass the viewer status' do
        expect(subject[:isSuperuser]).to be false
        expect(subject[:isViewer]).to be true
        expect(subject[:hasToolboxTab]).to be true
        expect(subject[:canViewGrades]).to be true
      end
    end
  end
end
