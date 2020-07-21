describe HubEdos::StudentApi::V2::Feeds::WorkExperiences do
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

    it 'returns feed with student attributes' do
      result = subject.get
      expect(result[:feed]['workExperiences']).to be
      expect(result[:feed]['workExperiences'].count).to eq 1
      expect(result[:feed]['workExperiences'][0]['id']).to be
      expect(result[:feed]['workExperiences'][0]['employer']).to be
      expect(result[:feed]['workExperiences'][0]['address']).to be
      expect(result[:feed]['workExperiences'][0]['phone']).to be
      expect(result[:feed]['workExperiences'][0]['fullTimePercentage']).to be
      expect(result[:feed]['workExperiences'][0]['weeklyHours']).to be
      expect(result[:feed]['workExperiences'][0]['payRate']).to be
      expect(result[:feed]['workExperiences'][0]['payCurrency']).to be
      expect(result[:feed]['workExperiences'][0]['payFrequency']).to be
      expect(result[:feed]['workExperiences'][0]['description']).to be
      expect(result[:feed]['workExperiences'][0]['retireDate']).to be
    end
  end
end
