describe HubEdos::StudentApi::V2::Feeds::StudentAttributes do
  let(:uid) { random_id }
  subject { described_class.new(fake: true, user_id: random_id) }

  context '#get' do
    it 'filters out base attributes' do
      result = subject.get
      expect(result[:statusCode]).to eq 200
      expect(result[:feed].has_key?('names')).to eq false
      expect(result[:feed].has_key?('identifiers')).to eq false
      expect(result[:feed].has_key?('affiliations')).to eq false
    end

    it 'returns feed with confidential boolean' do
      result = subject.get
      expect(result[:feed]['confidential']).to eq false
    end

    it 'returns feed with student attributes' do
      result = subject.get
      expect(result[:feed]['studentAttributes']).to be
      expect(result[:feed]['studentAttributes'].count).to eq 21
      result[:feed]['studentAttributes'].each do |studentAttribute|
        expect(studentAttribute['type']['code']).to be
        expect(studentAttribute['type']['description']).to be
      end
    end
  end
end
