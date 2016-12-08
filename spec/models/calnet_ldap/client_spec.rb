describe CalnetLdap::Client do

  it 'should initialize with a configured Net::LDAP object' do
    ldap = subject.instance_variable_get :@ldap
    expect(ldap).to be_a Net::LDAP
    expect(ldap.host).to eq 'nds-test.berkeley.edu'
    expect(ldap.port).to eq 636
    if ENV['RAILS_ENV'] == 'test'
      auth = ldap.instance_variable_get :@auth
      expect(auth[:username]).to eq 'uid=someApp,ou=applications,dc=berkeley,dc=edu'
      expect(auth[:password]).to eq 'someMumboJumbo'
    end
  end

  it 'should search and return people', testext: true do
    results = subject.send :search, {
      base: CalnetLdap::Client::PEOPLE_DN,
      filter: Net::LDAP::Filter.eq('uid', '212373')
    }
    expect(results).to have(1).item
    item = results[0]
    expect(item[:berkeleyedutestidflag]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:givenname]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:displayname]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:berkeleyedufirstname]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:berkeleyedulastname]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:cn]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:sn]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:mail]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:berkeleyeduaffiliations]).to be_an Enumerable
    expect(item[:berkeleyeduismemberof]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:berkeleyedutestidflag].count).to eq 1
    expect(item[:givenname].count).to eq 1
    expect(item[:displayname].count).to eq 1
    expect(item[:berkeleyedufirstname].count).to eq 1
    expect(item[:berkeleyedulastname].count).to eq 1
    expect(item[:cn].count).to eq 1
    expect(item[:sn].count).to eq 1
    expect(item[:mail].count).to eq 1
    expect(item[:uid][0]).to eq '212373'
    expect(item[:berkeleyedutestidflag][0]).to be_truthy
    expect(item[:displayname][0]).to eq 'AFF-GUEST TEST'
    expect(item[:berkeleyedufirstname][0]).to eq 'AFF-GUEST'
    expect(item[:berkeleyedulastname][0]).to eq 'TEST'
    expect(item[:cn][0]).to eq 'TEST, AFF-GUEST'
    expect(item[:sn][0]).to eq 'TEST'
    # IST alters 'mail' attribute value to generate events in the LDAP changelog
    # to monitor their real-time sync processes. Cannot rely on specific test value.
    expect(item[:mail][0]).to be_a Net::BER::BerIdentifiedString
  end

  it 'should receive array when querying for modified guests', testext: true do
    result = subject.guests_modified_since(Time.now.utc - 1.hour)
    expect(result).to be_an Array
  end

  it 'should have access to dependent attributes for guest entries', testext: true do
    results = subject.send :search, {
      base: CalnetLdap::Client::GUEST_DN,
      filter: Net::LDAP::Filter.eq('uid', '11000023')
    }
    expect(results).to have(1).item
    item = results[0]
    expect(item[:uid]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:givenname]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:sn]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:mail]).to be_a Net::BER::BerIdentifiedArray
    expect(item[:uid][0]).to eq '11000023'
    expect(item[:givenname][0]).to eq 'RickGuest'
    expect(item[:sn][0]).to eq 'Jaffe'
    expect(item[:mail][0]).to eq 'rjaffe@lmi.net'
  end

  it 'performs a bulk query on a mixed person-and-guest set of UIDs', testext: true do
    results = subject.search_by_uids %w(212373 11000023)
    expect(results).to have(2).items
    expect(results.find { |result| result[:sn][0] == 'TEST' }).to be_present
    expect(results.find { |result| result[:sn][0] == 'Jaffe' }).to be_present
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

  context 'search by name', testext: true do
    it 'should skip search when input is blank or incomplete' do
      expect(subject.search_by_name nil).to be_empty
      expect(subject.search_by_name '  ').to be_empty
      expect(subject.search_by_name ' Mr. ').to be_empty
    end

    it 'should get same result count when actual name fragments' do
      results_with_comma = subject.search_by_name ' man Jr., jo'
      expect(results_with_comma).to_not be_empty
      expect(subject.search_by_name 'Jo  MAN M.A.').to have(results_with_comma.length).items
    end
  end

end
