describe User::Api do
  let(:uid) { random_id }
  let(:original_delegate_user_id) { nil }
  let(:preferred_name) { 'Sid Vicious' }
  let(:has_advisor_role) { false }
  let(:has_student_role) { false }
  let(:edo_roles) do
    {
      advisor: has_advisor_role,
      student: has_student_role
    }
  end
  let(:edo_attributes) do
    {
      person_name: preferred_name,
      student_id: '1234567890',
      campus_solutions_id: '1234567890',
      is_legacy_student: false,
      official_bmail_address: 'foo@foo.com',
      roles: edo_roles
    }
  end
  let(:ldap_attributes) { {} }

  shared_context 'has no delegate students' do
    let(:delegate_students) { {} }
  end

  shared_context 'has delegate students' do
    let(:delegate_students) {
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
    }
  end

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

  describe '#preferred_name' do
    include_context 'has no delegate students'
    let(:has_student_role) { true }

    describe 'setting user attributes' do
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
    end
  end

  describe '#get_feed' do
    let(:feed) { User::Api.new(uid).get_feed }
    include_context 'has no delegate students'

    it 'should return a user data structure with default values' do
      expect(feed[:preferredName]).to eq ''
      expect(feed[:isLegacyStudent]).to be false
      expect(feed[:isDelegateUser]).to be false
      expect(feed[:showSisProfileUI]).to be false
      expect(feed[:hasAcademicsTab]).to be false
      expect(feed[:canViewGrades]).to be false
      expect(feed[:hasToolboxTab]).to be false
      expect(feed[:hasBadges]).to be false
      expect(feed[:officialBmailAddress]).to eq nil
      expect(feed[:campusSolutionsID]).to eq '1234567890'
      expect(feed[:sid]).to eq nil
      expect(feed[:isDirectlyAuthenticated]).to be true
      expect(feed[:canActOnFinances]).to be true
    end

    context 'student user' do
      let(:has_student_role) { true }
      it 'sets student-specific attributes' do
        expect(feed[:preferredName]).to eq preferred_name
        expect(feed[:officialBmailAddress]).to eq 'foo@foo.com'
        expect(feed[:sid]).to eq '1234567890'
      end
      it 'shows My Academics tab' do
        expect(feed[:hasAcademicsTab]).to be true
      end
      it 'shows bConnected badges' do
        expect(feed[:hasBadges]).to be true
      end
      it 'shows profile' do
        expect(feed[:showSisProfileUI]).to be true
      end
      it 'allows viewing grades' do
        expect(feed[:canViewGrades]).to be true
      end
    end

    context 'advisor user' do
      let(:has_advisor_role) { true }
      it 'hides My Academics tab' do
        expect(feed[:hasAcademicsTab]).to be false
      end
      it 'shows bConnected badges' do
        expect(feed[:hasBadges]).to be true
      end
      it 'shows profile' do
        expect(feed[:showSisProfileUI]).to be true
      end
      it 'allows viewing grades' do
        expect(feed[:canViewGrades]).to be true
      end
    end

    context 'delegate user' do
      let(:privilege_view_grades) { false }
      let(:privilege_view_enrollments) { false }
      let(:privilege_financial) { false }
      let(:privilege_phone) { false }
      let(:feed) {
        session = {
          'user_id' => uid,
          SessionKey.original_delegate_user_id => original_delegate_user_id
        }
        User::Api.from_session(session).get_feed
      }

      shared_examples 'a user viewing their own data' do
        it 'is directly authenticated' do
          expect(feed[:isDirectlyAuthenticated]).to be true
        end
      end
      shared_examples 'a user emulating someone else' do
        it 'is not directly authenticated' do
          expect(feed[:isDirectlyAuthenticated]).to be false
        end
      end

      before do
        allow(Cal1card::Photo).to receive(:new).and_call_original
        allow(Cal1card::Photo).to receive(:new).with(uid).and_return double(get_feed: {})
      end

      context 'never nominated as delegate' do
        include_context 'has no delegate students'
        let(:response) { nil }
        it_behaves_like 'a user viewing their own data'
        it 'hides My Toolbox tab' do
          expect(feed[:hasToolboxTab]).to be false
        end
        it 'hides bConnected badges' do
          expect(feed[:hasBadges]).to be false
        end
        it 'hides profile' do
          expect(feed[:showSisProfileUI]).to be false
        end
        it 'withholds delegate role' do
          expect(feed[:isDelegateUser]).to be false
          expect(feed[:delegateActingAsUid]).to be false
        end
        it 'assigns privileges relevant to the delegate' do
          expect(feed[:canViewGrades]).to be false
          expect(feed[:canActOnFinances]).to be true
        end
      end

      context 'formerly nominated as delegate' do
        include_context 'has no delegate students'
        let(:response) { { feed: { students: [] } } }
        it_behaves_like 'a user viewing their own data'
        it 'hides My Toolbox tab' do
          expect(feed[:hasToolboxTab]).to be false
        end
        it 'hides profile' do
          expect(feed[:showSisProfileUI]).to be false
        end
        it 'hides bConnected badges' do
          expect(feed[:hasBadges]).to be false
        end
        it 'withholds delegate role' do
          expect(feed[:isDelegateUser]).to be false
        end
        it 'assigns privileges relevant to the delegate' do
          expect(feed[:canViewGrades]).to be false
          expect(feed[:canActOnFinances]).to be true
        end
      end

      context 'currently a delegate' do
        include_context 'has delegate students'
        let(:campus_solutions_id) { random_id }

        context 'before view-as session' do
          it_behaves_like 'a user viewing their own data'
          it 'shows My Toolbox tab' do
            expect(feed[:hasToolboxTab]).to be true
            expect(feed[:hasDashboardTab]).to be false
            expect(feed[:hasAcademicsTab]).to be false
            expect(feed[:hasFinancialsTab]).to be false
            expect(feed[:hasCampusTab]).to be false
          end
          it 'hides profile' do
            expect(feed[:showSisProfileUI]).to be false
          end
          it 'hides bConnected badges' do
            expect(feed[:hasBadges]).to be false
          end
          it 'assigns delegate role' do
            expect(feed[:isDelegateUser]).to be true
          end
          it 'assigns privileges relevant to the delegate' do
            expect(feed[:canViewGrades]).to be false
            expect(feed[:canActOnFinances]).to be true
          end

          context 'also has another role' do
            let(:has_advisor_role) { true }
            it 'shows tabs relevant to both delegates and advisors' do
              expect(feed[:hasToolboxTab]).to be true
              expect(feed[:hasDashboardTab]).to be true
              expect(feed[:hasAcademicsTab]).to be false
              expect(feed[:hasFinancialsTab]).to be false
              expect(feed[:hasCampusTab]).to be true
            end
            it 'shows profile' do
              expect(feed[:showSisProfileUI]).to be true
            end
            it 'shows bConnected badges' do
              expect(feed[:hasBadges]).to be true
            end
            it 'assigns privileges relevant to both delegates and advisors' do
              expect(feed[:canViewGrades]).to be true
              expect(feed[:canActOnFinances]).to be true
            end
          end
        end
        context 'view-as session' do
          let(:original_delegate_user_id) { random_id }
          let(:ldap_attributes) { {roles: {student: true}} }
          it_behaves_like 'a user emulating someone else'

          context 'is allowed to see student\'s grades' do
            let(:privilege_view_grades) { true }
            it 'shows My Academics tab' do
              expect(feed[:hasDashboardTab]).to be false
              expect(feed[:hasToolboxTab]).to be false
              expect(feed[:hasAcademicsTab]).to be true
              expect(feed[:hasFinancialsTab]).to be false
            end
            it 'hides profile' do
              expect(feed[:showSisProfileUI]).to be false
            end
            it 'hides bConnected badges' do
              expect(feed[:hasBadges]).to be false
            end
            it 'withholds delegate role' do
              expect(feed[:isDelegateUser]).to be false
            end
            it 'assigns privileges relevant to the student' do
              expect(feed[:canViewGrades]).to be true
              expect(feed[:canActOnFinances]).to be false
            end
          end
          context 'is allowed to see student\'s enrollments' do
            let(:privilege_view_enrollments) { true }
            it 'shows My Academics tab' do
              expect(feed[:hasDashboardTab]).to be false
              expect(feed[:hasToolboxTab]).to be false
              expect(feed[:hasAcademicsTab]).to be true
              expect(feed[:hasFinancialsTab]).to be false
            end
            it 'hides profile' do
              expect(feed[:showSisProfileUI]).to be false
            end
            it 'hides bConnected badges' do
              expect(feed[:hasBadges]).to be false
            end
            it 'assigns privileges relevant to the student' do
              expect(feed[:canViewGrades]).to be false
              expect(feed[:canActOnFinances]).to be false
            end
          end
          context 'is allowed to see student\'s finances' do
            let(:privilege_financial) { true }
            it 'shows My Finances tab' do
              expect(feed[:hasDashboardTab]).to be false
              expect(feed[:hasToolboxTab]).to be false
              expect(feed[:hasAcademicsTab]).to be false
              expect(feed[:hasFinancialsTab]).to be true
            end
            it 'hides profile' do
              expect(feed[:showSisProfileUI]).to be false
            end
            it 'assigns privileges relevant to the student' do
              expect(feed[:canViewGrades]).to be false
              expect(feed[:canActOnFinances]).to be true
            end
          end
        end
      end
    end
  end

  context 'with legacy data' do
    include_context 'has no delegate students'
    let(:feed) { User::Api.new(uid).get_feed }
    let(:edo_attributes) do
      {
        person_name: preferred_name,
        campus_solutions_id: '12345678', # 8-digit ID means legacy
        is_legacy_student: true,
        roles: {
          student: true,
          exStudent: false,
          faculty: false,
          staff: false
        }
      }
    end
    it 'should show SIS profile for legacy students' do
      expect(feed[:isLegacyStudent]).to be true
      expect(feed[:showSisProfileUI]).to be true
    end
  end

  context 'session metadata' do
    include_context 'has no delegate students'
    it 'should have a null first_login time for a new user' do
      feed = User::Api.new(uid).get_feed
      expect(feed[:firstLoginAt]).to be_nil
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

      User::Api.delete uid

      expect(User::Data.where :uid => uid).to eq []
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
        feed = User::Api.new(uid).get_feed
        expect(feed[:hasAcademicsTab]).to eq false
        expect(feed[:canViewGrades]).to be false
      end
    end
  end

  describe 'profile source of record' do
    include_context 'has no delegate students'
    let(:has_student_role) { true }
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
      let(:edo_attributes) do
        {
          person_name: preferred_name,
          campus_solutions_id: '12345678', # 8-digit ID means legacy
          is_legacy_student: true,
          roles: {
          }
        }
      end
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
    include_context 'has no delegate students'
    let(:has_student_history) { false }
    before {
      allow(User::HasStudentHistory).to receive(:new).and_return(model = double)
      allow(model).to receive(:has_student_history?).and_return has_student_history
    }

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
    context 'has student history' do
      let(:ldap_attributes) { {roles: { :student => false, :exStudent => false, :faculty => false, :staff => false }} }
      let(:edo_attributes) { {roles: {}} }
      let(:has_student_history) { true }
      it { should be true }
    end
  end

  describe 'My Toolbox tab' do
    include_context 'has no delegate students'
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
      let(:edo_attributes) { {} }
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
    include_context 'has no delegate students'
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
        isLegacyStudent: true,
        roles: {
          student: true,
          registered: true,
          exStudent: false,
          faculty: false,
          staff: false,
          guest: false,
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
        isLegacyStudent: true,
        roles: {
          student: false,
          registered: false,
          exStudent: true,
          faculty: true,
          staff: false,
          guest: false,
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
              guest: false
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

    context 'when ex-student is reported by CS as now again active' do
      let(:uid) { '2040' }
      let(:edo_attributes) do
        {
          roles: {
            student: true
          }
        }
      end
      it 'should give precedence to CS' do
        expect(feed[:roles][:exStudent]).to be_falsey
        expect(feed[:roles][:student]).to eq true
      end
    end
  end

  context 'permissions' do
    include_context 'has no delegate students'
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
        expect(subject[:hasAcademicsTab]).to be false
        expect(subject[:canViewGrades]).to be false
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
        expect(subject[:canViewGrades]).to be false
      end
    end
  end
end
