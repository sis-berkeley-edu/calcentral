describe HubEdos::StudentApi::V2::Gender do
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

    it 'returns feed with gender' do
      result = subject.get
      expect(result[:feed]['gender']).to be
      expect(result[:feed]['gender']['genderOfRecord']['code']).to eq 'M'
      expect(result[:feed]['gender']['genderOfRecord']['description']).to eq 'Male'
      expect(result[:feed]['gender']['discloseGenderOfRecord']).to eq true
      expect(result[:feed]['gender']['fromDate']).to eq '2016-05-10'
    end
  end
end
