describe User::AuthenticationValidator do
  let(:auth_uid) { random_id }
  let(:feature_flag) { true }
  before do
    allow(Settings.features).to receive(:authentication_validator).and_return feature_flag
  end

  describe '#held_applicant?' do
    let(:nil_cs_affiliations) do
      {
        statusCode: 200,
        feed: {
          'student' =>
            {
              'affiliations' => nil
            }
        }
      }
    end
    let(:applicant_applied_cs_affiliation) do
      {
        statusCode: 200,
        feed: {
          'student'=>
            {'affiliations'=>
               [{'type'=>{'code'=>'APPLICANT', 'description'=>'Applicant'},
                 'detail'=> 'Applied',
                 'status'=> {
                   'code'=>'ACT',
                   'description'=>'Active'},
                 'fromDate'=>'2016-01-06'}]
            }
        },
        studentNotFound: nil
      }
    end
    let(:held_cs_affiliations) do
      {
        statusCode: 200,
        feed: {
          'student'=>
            {'affiliations'=>
              [{'type'=>{'code'=>'APPLICANT', 'description'=>'Applicant'},
                'detail'=> 'Admitted',
                'status'=> {
                  'code'=>'ACT',
                  'description'=>'Active'},
                'fromDate'=>'2016-01-06'}]
            }
        },
        studentNotFound: nil
      }
    end
    let(:released_cs_affiliations) do
      {
        statusCode: 200,
        feed: {
          'student'=>
            {'affiliations'=>
              [{'type'=>
                {'code'=>'ADMT_UX',
                  'description'=>'Admitted Students CalCentral Access'},
                'status'=> {
                  'code'=>'ACT',
                  'description'=>'Active'},
                'fromDate'=>'2016-01-11'},
                {'type'=>{'code'=>'APPLICANT', 'description'=>'Applicant'},
                  'detail' => 'Admitted',
                  'status'=> {
                    'code'=>'ACT',
                    'description'=>'Active'},
                  'fromDate'=>'2016-01-06'}]}
        },
        studentNotFound: nil
      }
    end
    let(:nil_ldap_roles) do
      {
        roles: {}
      }
    end
    let(:staff_ldap_roles) do
      {
        roles: {
          staff: true
        }
      }
    end
    let(:undergrad_sir_admit) do
      {
        sirStatuses: [
          { isUndergraduate: true }
        ]
      }
    end
    let(:multiple_sir_admit) do
      {
        sirStatuses: [
          { isUndergraduate: true },
          {}
        ]
      }
    end
    let(:graduate_sir_admit) do
      {
        sirStatuses: [
          { isUndergraduate: false }
        ]
      }
    end
    let(:ldap_affiliations) { nil }
    let(:sir_statuses) { nil }
    before do
      HubEdos::Affiliations.stub_chain(:new, :get).and_return cs_affiliations
      CalnetLdap::UserAttributes.stub_chain(:new, :get_feed).and_return ldap_affiliations
      CampusSolutions::Sir::SirStatuses.stub_chain(:new, :get_feed).and_return sir_statuses
    end
    subject { User::AuthenticationValidator.new(auth_uid).held_applicant? }
    context 'nil affiliations from all' do
      let(:cs_affiliations) { nil_cs_affiliations }
      it 'should return false without requesting data from LDAP or SirStatuses' do
        expect(subject).to eql(false)
        expect(CalnetLdap::UserAttributes).not_to receive(:new)
        expect(CampusSolutions::Sir::SirStatuses).not_to receive(:new)
      end
    end
    context 'no CS affiliations, existing LDAP affiliations' do
      let(:cs_affiliations) { nil }
      let(:ldap_affiliations) { staff_ldap_roles }
      it 'should return false without requesting data from LDAP or SirStatuses' do
        expect(subject).to eql(false)
        expect(CalnetLdap::UserAttributes).not_to receive(:new)
        expect(CampusSolutions::Sir::SirStatuses).not_to receive(:new)
      end
    end
    context 'pending-admit CS affiliation, no LDAP affiliations, undergraduate new admit' do
      let(:cs_affiliations) { held_cs_affiliations }
      let(:sir_statuses) { undergrad_sir_admit }
      it 'should return true' do
        expect(subject).to eql(true)
      end
    end
    context 'pending-admit CS affiliation, existing LDAP affiliations, undergraduate new admit' do
      let(:cs_affiliations) { held_cs_affiliations }
      let(:ldap_affiliations) { staff_ldap_roles }
      it 'should return false without requesting data from SirStatuses' do
        expect(subject).to eql(false)
        expect(CampusSolutions::Sir::SirStatuses).not_to receive(:new)
      end
    end
    context 'pending-admit CS affiliation, no LDAP affiliations, multiple new admit' do
      let(:cs_affiliations) { held_cs_affiliations }
      let(:sir_statuses) { multiple_sir_admit }
      it 'should return false' do
        expect(subject).to eql(false)
      end
    end
    context 'pending-admit CS affiliation, no LDAP affiliations, graduate new admit' do
      let(:cs_affiliations) { held_cs_affiliations }
      let(:sir_statuses) { graduate_sir_admit }
      it 'should return false' do
        expect(subject).to eql(false)
      end
    end
    context 'released-admit CS affiliation, no LDAP affiliations, undergraduate new admit' do
      let(:cs_affiliations) { released_cs_affiliations }
      it 'should return false without requesting data from LDAP or SirStatuses' do
        expect(subject).to eql(false)
        expect(CalnetLdap::UserAttributes).not_to receive(:new)
        expect(CampusSolutions::Sir::SirStatuses).not_to receive(:new)
      end
    end
    context 'multiple CS affiliations, no LDAP affiliations, undergraduate new admit' do
      let(:cs_affiliations) do
        {
          statusCode: 200,
          feed:
            {'student'=>
              {'affiliations'=>
                [{'type'=>{'code'=>'STUDENT', 'description'=>''},
                  'status'=> {
                    'code'=>'ACT',
                    'description'=>'Active'},
                  'fromDate'=>'2015-12-14'},
                  {'type'=>{'code'=>'UNDERGRAD', 'description'=>'Undergraduate Student'},
                    'status'=> {
                      'code'=>'INA',
                      'description'=>'Inactive'},
                    'fromDate'=>'2015-12-14'}]}},
          studentNotFound: nil
        }
      end
      it 'should return false without requesting data from LDAP or SirStatuses' do
        expect(subject).to eql(false)
        expect(CalnetLdap::UserAttributes).not_to receive(:new)
        expect(CampusSolutions::Sir::SirStatuses).not_to receive(:new)
      end
    end
    context 'Reverted released-admit, no LDAP affiliations, undergraduate new admit' do
      let(:cs_affiliations) do
        {
          statusCode: 200,
          feed:
            {'student'=>
              {'affiliations'=>
                [{'type'=>
                  {'code'=>'ADMT_UX',
                    'description'=>'Admitted Students CalCentral Access'},
                  'status'=> {
                    'code'=>'INA',
                    'description'=>'Inactive'},
                  'fromDate'=>'2016-01-11'},
                  {'type'=>{'code'=>'APPLICANT', 'description'=>'Applicant'},
                    'detail' => 'Admitted',
                    'status'=> {
                      'code'=>'ACT',
                      'description'=>'Active'},
                    'fromDate'=>'2016-01-06'}]}},
          studentNotFound: nil
        }
      end
      let(:ldap_affiliations) { nil_ldap_roles }
      let(:sir_statuses) { undergrad_sir_admit }
      it 'should return true' do
        expect(subject).to eql(true)
      end
    end
  end

  describe '#validated_user_id' do
    before do
      allow_any_instance_of(User::AuthenticationValidator).to receive(:held_applicant?).and_return(is_held)
    end
    subject { User::AuthenticationValidator.new(auth_uid) }
    context 'user is only known as a held applicant' do
      let(:is_held) { true }
      it 'does not accept the session user_id' do
        expect(subject.validated_user_id).to be_nil
      end
    end
    context 'user is an old friend' do
      let(:is_held) { false }
      it 'allows the session user_id' do
        expect(subject.validated_user_id).to eq auth_uid
      end
    end
  end

  context 'feature disabled' do
    let(:feature_flag) { false }
    it 'should not waste time checking affiliations' do
      expect(CampusOracle::Queries).to receive(:get_basic_people_attributes).never
      expect(HubEdos::Affiliations).to receive(:new).never
      expect(User::AuthenticationValidator.new(auth_uid).validated_user_id).to eq auth_uid
    end
  end

  describe 'caching' do
    let(:cache_key) { User::AuthenticationValidator.cache_key(auth_uid) }
    before do
      allow_any_instance_of(User::AuthenticationValidator).to receive(:held_applicant?).and_return(is_held)
      allow(Settings.cache.expiration).to receive(:marshal_dump).and_return({
        'User::AuthenticationValidator'.to_sym => 8.hours,
        'User::AuthenticationValidator::short'.to_sym => 1.second
      })
    end
    subject { User::AuthenticationValidator.new(auth_uid) }
    context 'in a stable institutional relationship' do
      let(:is_held) { false }
      it 'remembers the good times' do
        expect(Rails.cache).to receive(:read).once.with(cache_key).and_call_original
        expect(Rails.cache).to receive(:write).once.with(
          cache_key,
          anything,
          {
            expires_in: 8.hours,
            force: true
          }
        )
        subject.validated_user_id
      end
    end
    context 'just met' do
      let(:is_held) { true }
      it 'hopes to make a friend' do
        expect(Rails.cache).to receive(:read).once.with(cache_key).and_call_original
        expect(Rails.cache).to receive(:write).once.with(
          cache_key,
          anything,
          {
            expires_in: 1.second,
            force: true
          }
        )
        subject.validated_user_id
      end
    end
  end
end
