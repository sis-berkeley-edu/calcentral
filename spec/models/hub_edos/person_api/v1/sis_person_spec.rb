describe HubEdos::PersonApi::V1::SisPerson do
  let(:uid) { random_id }
  subject { described_class.new(fake: true, user_id: random_id) }

  context '#get' do
    let(:result) { subject.get }

    it 'returns data without api wrapper' do
      expect(result[:statusCode]).to eq 200
      expect(result[:feed].keys).to eq ['identifiers', 'names', 'affiliations', 'emails']
    end

    it 'returns feed with identifiers' do
      expect(result[:statusCode]).to eq 200
      expect(result[:feed]['identifiers'].count).to eq 4
      result[:feed]['identifiers'].each do |identifier|
        expect(identifier.has_key?('type')).to eq true
        expect(identifier.has_key?('id')).to eq true
        expect(identifier.has_key?('disclose')).to eq true
      end
    end

    it 'returns feed with names' do
      expect(result[:statusCode]).to eq 200
      expect(result[:feed]['names'].count).to eq 2
      result[:feed]['names'].each do |name|
        expect(name.has_key?('type')).to eq true
        expect(name.has_key?('familyName')).to eq true
        expect(name.has_key?('givenName')).to eq true
        expect(name.has_key?('formattedName')).to eq true
        expect(name.has_key?('preferred')).to eq true
        expect(name.has_key?('disclose')).to eq true
      end
    end

    it 'returns feed with affiliations' do
      expect(result[:statusCode]).to eq 200
      expect(result[:feed]['affiliations'].count).to eq 4
      result[:feed]['affiliations'].each do |affiliation|
        expect(affiliation.has_key?('type')).to eq true
        expect(affiliation['type'].has_key?('code')).to eq true
        expect(affiliation['type'].has_key?('description')).to eq true
        expect(affiliation.has_key?('detail')).to eq true
        expect(affiliation.has_key?('status')).to eq true
        expect(affiliation.has_key?('fromDate')).to eq true
      end
    end

    it 'returns feed with emails' do
      expect(result[:statusCode]).to eq 200
      expect(result[:feed]['emails'].count).to eq 2
      result[:feed]['emails'].each do |email|
        expect(email.has_key?('type')).to eq true
        expect(email['type'].has_key?('code')).to eq true
        expect(email['type'].has_key?('description')).to eq true
        expect(email.has_key?('emailAddress')).to eq true
        expect(email.has_key?('primary')).to eq true
        expect(email.has_key?('disclose')).to eq true
        expect(email.has_key?('uiControl')).to eq true
        expect(email['uiControl'].has_key?('code')).to eq true
        expect(email['uiControl'].has_key?('description')).to eq true
      end
    end
  end
end
