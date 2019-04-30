describe HubEdos::V2::Student do
  let(:uid) { random_id }
  subject { HubEdos::V2::Student.new(fake: true, user_id: random_id) }

  context '#get' do
    it 'returns feed' do
      result = subject.get
      expect(result[:statusCode]).to eq 200
      expect(result[:feed]['confidential']).to eq false
      expect(result[:feed]['names']).to be
      expect(result[:feed]['identifiers']).to be
      expect(result[:feed]['affiliations']).to be
      expect(result[:feed]['holds']).to be
      expect(result[:feed]['academicStatuses'].count).to eq 2
      expect(result[:feed]['academicStatuses'][0]['cumulativeGPA']).to be
      expect(result[:feed]['academicStatuses'][0]['cumulativeUnits']).to be
      expect(result[:feed]['academicStatuses'][0]['studentCareer']).to be
      expect(result[:feed]['academicStatuses'][0]['studentPlans']).to be
      expect(result[:feed]['addresses']).to be
      expect(result[:feed]['phones']).to be
      expect(result[:feed]['emails']).to be
      expect(result[:feed]['emergencyContacts']).to be
      expect(result[:feed]['registrations']).to be
    end
  end
end
