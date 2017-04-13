describe User::AggregatedAttributes do
  let(:uid) { random_id }
  let(:campus_solutions_id) { random_cs_id }
  let(:preferred_name) { 'Grigori Rasputin' }
  let(:first_name_from_edo) { 'Ed' }
  let(:last_name_from_edo) { 'O\'Houlihan' }
  let(:bmail_from_edo) { 'rasputin@berkeley.edu' }
  let(:base_edo_attributes) do
    {
      ldap_uid: uid,
      person_name: preferred_name,
      first_name: first_name_from_edo,
      last_name: last_name_from_edo,
      student_id: campus_solutions_id,
      campus_solutions_id: campus_solutions_id,
      official_bmail_address: bmail_from_edo
    }
  end
  let(:edo_attributes) do
    base_edo_attributes.merge(
      is_legacy_student: false,
      roles: {
        student: true
      }
    )
  end
  let(:first_name_from_ldap) { 'Ellen' }
  let(:last_name_from_ldap) { 'Dapper' }
  let(:bmail_from_ldap) { 'raspy@berkeley.edu' }
  let(:base_ldap_attributes) do
    {
      ldap_uid: uid,
      first_name: first_name_from_ldap,
      last_name: last_name_from_ldap,
      official_bmail_address: bmail_from_ldap,
      roles: {
        exStudent: true
      }
    }
  end
  let(:ldap_attributes) do
    base_ldap_attributes.merge(
      roles: {
        exStudent: true
      }
    )
  end

  subject { User::AggregatedAttributes.new(uid).get_feed }

  before(:each) do
    allow(HubEdos::UserAttributes).to receive(:new).with(user_id: uid).and_return double get: edo_attributes
    allow(CalnetLdap::UserAttributes).to receive(:new).with(user_id: uid).and_return double get_feed: ldap_attributes
    allow(CampusOracle::UserAttributes).to receive(:new).with(user_id: uid).and_return double(get_feed: {})
  end

  describe 'all systems available' do
    context 'Hub feed' do
      it 'should return edo user attributes' do
        expect(subject[:isLegacyStudent]).to be false
        expect(subject[:sisProfileVisible]).to be true
        expect(subject[:officialBmailAddress]).to eq bmail_from_edo
        expect(subject[:campusSolutionsId]).to eq campus_solutions_id
        expect(subject[:studentId]).to eq campus_solutions_id
        expect(subject[:ldapUid]).to eq uid
        expect(subject[:defaultName]).to eq preferred_name
        expect(subject[:firstName]).to eq first_name_from_edo
        expect(subject[:lastName]).to eq last_name_from_edo
        expect(subject[:roles][:exStudent]).to be_falsey
        expect(subject[:unknown]).to be_falsey
      end
    end
  end

  describe 'LDAP is fallback' do
    let(:ldap_attributes) do
      base_ldap_attributes.merge(
        roles: {
          student: is_active_student,
          exStudent: !is_active_student,
          faculty: false,
          staff: true
        }
      )
    end
    context 'active student' do
      let(:is_active_student) { true }
      it 'should prefer EDO' do
        expect(subject[:officialBmailAddress]).to eq bmail_from_edo
        expect(subject[:defaultName]).to eq preferred_name
        expect(subject[:firstName]).to eq first_name_from_edo
        expect(subject[:lastName]).to eq last_name_from_edo
        expect(subject[:roles][:student]).to be true
        expect(subject[:roles][:exStudent]).to be_falsey
        expect(subject[:unknown]).to be_falsey
      end
    end
    context 'former student according to LDAP' do
      let(:is_active_student) { false }
      it 'should still prefer EDO when EDO claims active student status' do
        expect(subject[:officialBmailAddress]).to eq bmail_from_edo
        expect(subject[:defaultName]).to eq preferred_name
        expect(subject[:firstName]).to eq first_name_from_edo
        expect(subject[:lastName]).to eq last_name_from_edo
        expect(subject[:roles][:student]).to be true
        expect(subject[:roles][:exStudent]).to be_falsey
        expect(subject[:unknown]).to be_falsey
      end
      context 'EDO does not know about former student status' do
        let(:edo_attributes) do
          base_edo_attributes.merge(
            is_legacy_student: false,
            roles: {
              advisor: true
            }
          )
        end
        it 'fills in former student status and other attributes from LDAP' do
          expect(subject[:officialBmailAddress]).to eq bmail_from_ldap
          expect(subject[:firstName]).to eq first_name_from_ldap
          expect(subject[:lastName]).to eq last_name_from_ldap
          expect(subject[:roles][:student]).to be false
          expect(subject[:roles][:exStudent]).to be true
          expect(subject[:roles][:advisor]).to be true
          expect(subject[:unknown]).to be_falsey
        end
      end
    end
    context 'applicant' do
      let(:edo_attributes) do
        base_edo_attributes.merge(
          roles: {
            staff: true,
            applicant: true
          }
        )
      end
      let(:is_active_student) { false }
      it 'should prefer EDO' do
        expect(subject[:officialBmailAddress]).to eq bmail_from_edo
        expect(subject[:firstName]).to eq first_name_from_edo
        expect(subject[:lastName]).to eq last_name_from_edo
        expect(subject[:roles][:applicant]).to be true
        expect(subject[:unknown]).to be_falsey
      end
    end
    context 'graduate' do
      let(:edo_attributes) do
        base_edo_attributes.merge(
          roles: {
            staff: true,
            graduate: true
          }
        )
      end
      let(:is_active_student) { true }
      it 'picks up EDO role' do
        expect(subject[:roles][:graduate]).to be true
        expect(subject[:unknown]).to be_falsey
      end
    end
    context 'unknown UID' do
      let(:edo_attributes) do
        {
          ldap_uid: uid
        }
      end
      let(:ldap_attributes) do
        {}
      end
      it 'succeeds but delivers the bad news' do
        expect(subject[:ldapUid]).to eq uid
        expect(subject[:unknown]).to be_truthy
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
        expect(subject[:officialBmailAddress]).to eq bmail_from_ldap
        expect(subject[:roles][:student]).to be true
        expect(subject[:roles][:exStudent]).to be false
        expect(subject[:ldapUid]).to eq uid
      end
    end
  end

end
