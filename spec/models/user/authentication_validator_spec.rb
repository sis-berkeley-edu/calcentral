describe User::AuthenticationValidator do
  let(:auth_uid) { random_id }
  let(:auth_handler) { { client: nil, handler: "BerkeleyAuthenticationHandler" } } # Default authentication handler
  let(:feature_flag) { true }
  before do
    allow(Settings.features).to receive(:authentication_validator).and_return feature_flag
    allow(described_class).to receive(:new).with(auth_uid, auth_handler).and_call_original
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
    let(:applicant_admitted_cs_affiliation) do
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
    let(:reverted_cs_affiliations) do
      {
        statusCode: 200,
        feed:
          {'student'=>
             {'affiliations'=>
                [{'type'=>
                    {'code'=>'ADMT_UX',
                     'description'=>'Admitted Students CalCentral Access'},
                  'status'=> {
                    'code'=>'ACT',
                    'description'=>'Active'},
                  'fromDate'=>'2016-01-11'},
                  {'type'=>{'code'=>'STUDENT', 'description'=>''},
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
    let(:ldap_affiliations) { nil }
    let(:slate_auth_handler_settings) { { client: 'Slate', handler: 'ClientAuthenticationHandler', handler_casv5: 'slateAuthenticationHandler' } }
    let(:slate_auth_handler) { { client: 'Slate', handler: 'ClientAuthenticationHandler' } }
    let(:slate_auth_handler_casv5) { { client: nil, handler: 'slateAuthenticationHandler' } }

    shared_examples 'it should not request data from LDAP' do
      it 'does not request data from LDAP' do
        expect(CalnetLdap::UserAttributes).not_to receive(:new)
      end
    end
    before do
      HubEdos::V1::Affiliations.stub_chain(:new, :get).and_return cs_affiliations
      CalnetLdap::UserAttributes.stub_chain(:new, :get_feed).and_return ldap_affiliations
      Settings.stub_chain(:slate_auth_handler).and_return slate_auth_handler_settings
    end
    subject { User::AuthenticationValidator.new(auth_uid, auth_handler).held_applicant? }

    context 'no CS affiliations' do
      let(:cs_affiliations) { nil_cs_affiliations }
      it 'should return false' do
        expect(subject).to eql(false)
      end
      include_examples 'it should not request data from LDAP'
    end

    context 'pending-admit CS affiliations' do
      let(:cs_affiliations) { applicant_admitted_cs_affiliation }

      context 'no LDAP affiliations' do
        context 'authenticated via CAS' do
          it 'should return true' do
            expect(subject).to eql(true)
          end
        end
        context 'authenticated via SSO from Slate' do
          context 'with CAS v5.3' do
            let(:auth_handler) { slate_auth_handler }
            it 'should return true' do
              expect(subject).to eql(true)
            end
            include_examples 'it should not request data from LDAP'
          end
          context 'with CAS v5.0' do
            let(:auth_handler) { slate_auth_handler_casv5 }
            it 'should return true' do
              expect(subject).to eql(true)
            end
            include_examples 'it should not request data from LDAP'
          end
        end
      end

      context 'existing LDAP affiliations' do
        context 'with CAS v5.3' do
          let(:auth_handler) { slate_auth_handler }
          it 'should return true' do
            expect(subject).to eql(true)
          end
          include_examples 'it should not request data from LDAP'
        end
        context 'with CAS v5.0' do
          let(:auth_handler) { slate_auth_handler_casv5 }
          it 'should return true' do
            expect(subject).to eql(true)
          end
          include_examples 'it should not request data from LDAP'
        end
      end
    end

    context 'released-admit CS affiliations' do
      let(:cs_affiliations) { released_cs_affiliations }

      context 'no LDAP affiliations' do
        context 'authenticated via CAS' do
          it 'should return false' do
            expect(subject).to eql(false)
          end
          include_examples 'it should not request data from LDAP'
        end

        context 'authenticated via SSO from Slate' do
          context 'with CAS v5.3' do
            let(:auth_handler) { slate_auth_handler }
            it 'should return false' do
              expect(subject).to eql(false)
            end
            include_examples 'it should not request data from LDAP'
          end
          context 'with CAS v5.0' do
            let(:auth_handler) { slate_auth_handler_casv5 }
            it 'should return false' do
              expect(subject).to eql(false)
            end
            include_examples 'it should not request data from LDAP'
          end
        end
      end

      context 'existing LDAP affiliations' do
        let(:ldap_affiliations) { staff_ldap_roles }
        context 'authenticated via CAS' do
          it 'should return false' do
            expect(subject).to eql(false)
          end
          include_examples 'it should not request data from LDAP'
        end

        context 'authenticated via SSO from Slate' do
          context 'with CAS v5.3' do
            let(:auth_handler) { slate_auth_handler }
            it 'should return false' do
              expect(subject).to eql(false)
            end
            include_examples 'it should not request data from LDAP'
          end
          context 'with CAS v5.0' do
            let(:auth_handler) { slate_auth_handler_casv5 }
            it 'should return false' do
              expect(subject).to eql(false)
            end
            include_examples 'it should not request data from LDAP'
          end
        end
      end
    end

    context 'reverted admit CS affiliations' do
      let(:cs_affiliations) { reverted_cs_affiliations }

      context 'no LDAP affiliations' do
        context 'authenticated via CAS' do
          it 'should return false' do
            expect(subject).to eql(false)
          end
          include_examples 'it should not request data from LDAP'
        end

        context 'authenticated via SSO from Slate' do
          context 'with CAS v5.3' do
            let(:auth_handler) { slate_auth_handler }
            it 'should return false' do
              expect(subject).to eql(false)
            end
            include_examples 'it should not request data from LDAP'
          end
          context 'with CAS v5.0' do
            let(:auth_handler) { slate_auth_handler_casv5 }
            it 'should return false' do
              expect(subject).to eql(false)
            end
            include_examples 'it should not request data from LDAP'
          end
        end
      end

      context 'existing LDAP affiliations' do
        let(:ldap_affiliations) { staff_ldap_roles }
        context 'authenticated via CAS' do
          it 'should return false' do
            expect(subject).to eql(false)
          end
          include_examples 'it should not request data from LDAP'
        end

        context 'authenticated via SSO from Slate' do
          context 'with CAS v5.3' do
            let(:auth_handler) { slate_auth_handler }
            it 'should return false' do
              expect(subject).to eql(false)
            end
            include_examples 'it should not request data from LDAP'
          end
          context 'with CAS v5.0' do
            let(:auth_handler) { slate_auth_handler_casv5 }
            it 'should return false' do
              expect(subject).to eql(false)
            end
            include_examples 'it should not request data from LDAP'
          end
        end
      end
    end

    context 'no user authentication (view-as)' do
      let(:cs_affiliations) { applicant_admitted_cs_affiliation }
      let(:auth_handler) { nil }
      it 'does not bother checking for slate auth handler' do
        expect(described_class).to receive(:is_slate_auth_handler?).never
      end
      it 'falls back to the default non-slate logic' do
        expect(subject).to eql(true)
      end
    end
  end

  describe '#validated_user_id' do
    before do
      allow_any_instance_of(User::AuthenticationValidator).to receive(:held_applicant?).and_return(is_held)
    end
    subject { User::AuthenticationValidator.new(auth_uid, auth_handler) }
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
      expect(HubEdos::V1::Affiliations).to receive(:new).never
      expect(User::AuthenticationValidator.new(auth_uid, auth_handler).validated_user_id).to eq auth_uid
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
    subject { User::AuthenticationValidator.new(auth_uid, auth_handler) }
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
