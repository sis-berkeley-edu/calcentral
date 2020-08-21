describe HubEdos::StudentApi::V2::Student::StudentAttributes do
  let(:uid) { random_id }
  let(:user) { double(uid: uid) }
  let(:sis_student_student_attributes_proxy) { double(get: api_response)}
  let(:api_response) do
    {
      statusCode: status_code,
      feed: feed,
      studentNotFound: nil
    }
  end
  let(:status_code) { 200 }
  let(:student_attributes) do
    [
      sir_deposit_waiver,
      entry_level_writing,
      senior_res_terms_satisfied
    ]
  end
  let(:sir_deposit_waiver) do
    {
      'type' => {
        'code' => 'AWDP',
        'description' => 'SIR Deposit Waiver'
      },
      'fromDate' => '2016-03-24'
    }
  end
  let(:entry_level_writing) do
    {
      'type' => {
        'code' => 'VELW',
        'description' => 'Entry Level Writing'
      },
      'fromDate' => '2016-08-29'
    }
  end
  let(:senior_res_terms_satisfied) do
    {
      'type' => {
        'code' => 'VSEN',
        'description' => 'Senior Res Terms Satisfied'
      },
      'fromDate' => '2018-11-29'
    }
  end

  let(:feed) do
    {
      'studentAttributes' => student_attributes,
      'confidential' => false
    }
  end
  subject { described_class.new(user) }
  before do
    allow(HubEdos::StudentApi::V2::Feeds::StudentAttributes).to receive(:new).with(user_id: uid).and_return(sis_student_student_attributes_proxy)
  end

  describe '#all' do
    context 'when http api response fails' do
      let(:status_code) { 500 }
      it 'returns empty array' do
        expect(subject.all).to eq []
      end
    end

    context 'when http api response is successful' do
      let(:status_code) { 200 }
      it 'returns array of HubEdos::StudentApi::V2::StudentAttribute objects' do
        result = subject.all
        expect(result).to be_an_instance_of Array
        expect(result.first).to be_an_instance_of HubEdos::StudentApi::V2::Student::StudentAttribute
      end
    end
  end

  describe '#find_all_by_type_code' do
    let(:degree_awarded) do
      {
        'type' => {
          'code' => 'RDGA',
          'description' => 'Degree Awarded'
        },
        'fromDate' => '2020-08-03'
      }
    end
    let(:type_code) { 'RDGA' }
    context 'when object in collection responds with matching type code' do
      let(:student_attributes) do
        [
          sir_deposit_waiver,
          entry_level_writing,
          degree_awarded
        ]
      end
      it 'returns matching object' do
        result = subject.find_all_by_type_code(type_code)
        expect(result.first.type_code).to eq 'RDGA'
      end
    end
    context 'when object in collection does not respond with matching type code' do
      let(:student_attributes) do
        [
          sir_deposit_waiver,
          entry_level_writing,
          senior_res_terms_satisfied
        ]
      end
      it 'returns nil' do
        result = subject.find_all_by_type_code(type_code)
        expect(result).to eq([])
      end
    end
  end
end
