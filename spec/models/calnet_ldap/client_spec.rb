describe CalnetLdap::Client do

  it 'should initialize with a configured Net::LDAP object' do
    ldap = subject.instance_variable_get :@ldap
    expect(ldap).to be_a Net::LDAP
    expect(ldap.host).to eq 'ldap-test.berkeley.edu'
    expect(ldap.port).to eq 636
    if ENV['RAILS_ENV'] == 'test'
      auth = ldap.instance_variable_get :@auth
      expect(auth[:username]).to eq 'uid=someApp,ou=applications,dc=berkeley,dc=edu'
      expect(auth[:password]).to eq 'someMumboJumbo'
    end
  end

  it 'batches bulk queries' do
    lots_of_uids = (CalnetLdap::Client::BATCH_QUERY_MAXIMUM * 4 + 1).times.map { rand(9999).to_s }
    fake_search_results = CalnetLdap::Client::BATCH_QUERY_MAXIMUM.times.map do
      {uid: [rand(9999).to_s]}
    end
    expect(subject).to receive(:search).exactly(5).times.with(hash_including base: CalnetLdap::Client::PEOPLE_DN).and_return fake_search_results
    expect(subject).to receive(:search).exactly(1).times.with(hash_including base: CalnetLdap::Client::GUEST_DN).and_return fake_search_results
    subject.search_by_uids lots_of_uids
  end

  it 'deals gracefully with errors' do
    allow_any_instance_of(Net::LDAP).to receive(:search).and_return(nil)
    results = subject.search_by_uid random_id
    expect(results).to eq nil
  end

  it 'tries to find a specific UID in all population groups' do
    uid = random_id
    expect(subject).to receive(:search).exactly(1).times.with(hash_including base: CalnetLdap::Client::PEOPLE_DN).and_return []
    expect(subject).to receive(:search).exactly(1).times.with(hash_including base: CalnetLdap::Client::GUEST_DN).and_return []
    expect(subject).to receive(:search).exactly(1).times.with(hash_including base: CalnetLdap::Client::ADVCON_DN).and_return []
    expect(subject).to receive(:search).exactly(1).times.with(hash_including base: CalnetLdap::Client::EXPIRED_DN).and_return [{uid: [uid]}]
    result = subject.search_by_uid uid
    expect(result[:uid]).to eq([uid])
  end

  context 'search by name with mock LDAP' do
    let(:expected_ldap_searches) { nil }
    before do
      allow(Net::LDAP::Filter).to receive(:eq).with('displayname', '*John* Doe*')
      allow(Net::LDAP::Filter).to receive(:eq).with('displayname', '*Doe* John*')
      expect(Net::LDAP).to receive(:new).and_return (ldap = double)
      expect(ldap).to receive(:search).exactly(expected_ldap_searches).times.and_return [ double ]
    end
    context 'do not include guest user search' do
      let(:expected_ldap_searches) { 1 }
      it 'should only ' do
        expect(subject.search_by_name('John Doe', false)).to_not be_empty
      end
    end
    context 'include guest user search' do
      let(:expected_ldap_searches) { 2 }
      it 'should only ' do
        expect(subject.search_by_name('John Doe', true)).to_not be_empty
      end
    end
  end

  describe '#search_by_name' do
    it 'should skip search when input is blank or incomplete' do
      expect(subject.search_by_name nil).to be_empty
      expect(subject.search_by_name '  ').to be_empty
      expect(subject.search_by_name ' Mr. ').to be_empty
    end
  end
end
