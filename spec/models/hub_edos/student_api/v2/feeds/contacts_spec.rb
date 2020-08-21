describe HubEdos::StudentApi::V2::Feeds::Contacts do
  let(:uid) { random_id }
  subject { described_class.new(fake: true, user_id: random_id) }

  context '#get' do
    it 'filters out base attributes' do
      result = subject.get
      expect(result[:statusCode]).to eq 200
      expect(result[:feed].has_key?('names')).to eq false
      expect(result[:feed].has_key?('identifiers')).to eq false
      expect(result[:feed].has_key?('affiliations')).to eq false
      expect(result[:feed].has_key?('confidential')).to eq false
    end

    context 'addresses' do
      let(:addresses) { subject.get[:feed]['addresses'] }
      it 'returns feed with addresses' do
        expect(addresses).to be
        expect(addresses.count).to eq 3
      end

      it 'converts \'stateCode\' properties to \'state\'' do
        expect(addresses).to be
        addresses.each do |address|
          expect(address.has_key?('stateCode')).to eq false
          expect(address.has_key?('state')).to eq true
        end
      end

      it 'converts \'postalCode\' properties to \'postal\'' do
        expect(addresses).to be
        addresses.each do |address|
          expect(address.has_key?('postalCode')).to eq false
          expect(address.has_key?('postal')).to eq true
        end
      end

      it 'converts \'countryCode\' properties to \'country\'' do
        expect(addresses).to be
        addresses.each do |address|
          expect(address.has_key?('countryCode')).to eq false
          expect(address.has_key?('country')).to eq true
        end
      end
    end

    context 'phone' do
      let(:phones) { subject.get[:feed]['phones'] }
      it 'returns feed with phones' do
        expect(phones).to be
        expect(phones.count).to eq 2
      end
    end

    context 'emails' do
      let(:emails) { subject.get[:feed]['emails'] }
      it 'returns feed with emails' do
        expect(emails).to be
        expect(emails.count).to eq 2
      end
    end

    context 'emergencyContacts' do
      let(:emergency_contacts) { subject.get[:feed]['emergencyContacts'] }
      it 'returns feed with emergencyContacts' do
        expect(emergency_contacts).to be
        expect(emergency_contacts.count).to eq 1
      end
    end
  end
end
