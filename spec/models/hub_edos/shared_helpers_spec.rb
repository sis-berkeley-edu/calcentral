describe HubEdos::SharedHelpers do
  describe '.filter_fields' do
    let(:input_hash) {
      {
        'names' => 'names content',
        'identifiers' => 'identifiers content',
        'affiliations' => 'affiliations content',
      }
    }
    let(:whitelisted_fields) { [] }
    subject { described_class.filter_fields(input_hash, whitelisted_fields) }

    context 'when whitelisted fields is nil' do
      let(:whitelisted_fields) { nil }
      it 'returns hash without modifications' do
        expect(subject['names']).to eq 'names content'
        expect(subject['identifiers']).to eq 'identifiers content'
        expect(subject['affiliations']).to eq 'affiliations content'
      end
    end
    context 'when whitelisted fields is empty' do
      let(:whitelisted_fields) { [] }
      it 'returns hash without modifications' do
        expect(subject['names']).to eq 'names content'
        expect(subject['identifiers']).to eq 'identifiers content'
        expect(subject['affiliations']).to eq 'affiliations content'
      end
    end
    context 'when whitelisted fields are present' do
      let(:whitelisted_fields) { ['identifiers'] }
      it 'returns hash with only whitelisted fields present' do
        expect(subject['names']).to eq nil
        expect(subject['affiliations']).to eq nil
        expect(subject['identifiers']).to eq 'identifiers content'
      end
    end
  end

  describe '.transform_address_keys' do
    let(:student_hash) {
      {
        'addresses' => [
          {
            'stateCode' => 'CA',
            'postalCode' => '94705',
            'countryCode' => 'USA',
          }
        ],
        'identifiers' => 'identifiers content',
      }
    }
    subject { described_class.transform_address_keys(student_hash) }
    context 'when address is not present' do
      before { student_hash.delete('addresses') }
      it 'returns object unchanged' do
        expect(subject.has_key?('addresses')).to eq false
        expect(subject['identifiers']).to eq 'identifiers content'
      end
    end
    context 'when address is present' do
      it 'returns with region codes renamed' do
        expect(subject.has_key?('addresses')).to eq true
        expect(subject['identifiers']).to eq 'identifiers content'
        expect(subject['addresses'][0].has_key?('stateCode')).to eq false
        expect(subject['addresses'][0].has_key?('postalCode')).to eq false
        expect(subject['addresses'][0].has_key?('countryCode')).to eq false
        expect(subject['addresses'][0]['state']).to eq 'CA'
        expect(subject['addresses'][0]['postal']).to eq '94705'
        expect(subject['addresses'][0]['country']).to eq 'USA'
      end
    end
  end
end
