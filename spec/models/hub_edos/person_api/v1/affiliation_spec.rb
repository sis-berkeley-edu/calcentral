describe HubEdos::PersonApi::V1::Affiliation do
  let(:type_code) { 'ALUMFORMER' }
  let(:detail) { 'Former Student' }
  let(:attributes) do
    {
      'type' => {
        'code' => type_code,
        'description' => 'Alum/Former Student',
      },
      'detail' => detail,
      'status' => {
        'code' => 'ACT',
        'description' => 'Active',
      },
      "fromDate" => "2019-04-12",
    }
  end
  subject { described_class.new(attributes) }
  its('type.code') { should eq('ALUMFORMER') }
  its(:from_date) { should be_an_instance_of(Date) }
  its('from_date.to_s') { should eq('2019-04-12') }

  describe '#matriculated_but_excluded?' do
    let(:result) { subject.matriculated_but_excluded? }
    context 'when affiliation is not an applicant' do
      let(:type_code) { 'ALUMFORMER' }
      it 'returns false' do
        expect(result).to eq false
      end
    end
    context 'when affiliation is an applicant' do
      let(:type_code) { 'APPLICANT' }
      context 'when detail indicates SIR completed' do
        let(:detail) { 'SIR Completed' }
        it 'returns true' do
          expect(result).to eq true
        end
      end
      context 'when detail indicates deposit pending' do
        let(:detail) { 'Deposit Pending' }
        it 'returns true' do
          expect(result).to eq true
        end
      end
      context 'when detail not indicating matriculation' do
        let(:detail) { 'Active' }
        it 'returns false' do
          expect(result).to eq false
        end
      end
    end
  end

  describe '#is_student?' do
    context 'when type code is \'STUDENT\'' do
      let(:type_code) { 'STUDENT' }
      it 'returns true' do
        expect(subject.is_student?).to eq true
      end
    end
    context 'when type code is not \'STUDENT\'' do
      let(:type_code) { 'ALUMFORMER' }
      it 'returns false' do
        expect(subject.is_student?).to eq false
      end
    end
  end

  describe '#to_json' do
    it 'returns expected json' do
      json = subject.to_json
      hash_result = JSON.parse(json)
      expect(hash_result['type']['code']).to eq 'ALUMFORMER'
      expect(hash_result['type']['description']).to eq 'Alum/Former Student'
      expect(hash_result['detail']).to eq 'Former Student'
      expect(hash_result['status']['code']).to eq 'ACT'
      expect(hash_result['status']['description']).to eq 'Active'
      expect(hash_result['fromDate']).to eq '2019-04-12'
    end
  end
end
