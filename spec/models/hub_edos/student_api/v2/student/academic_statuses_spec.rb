describe HubEdos::StudentApi::V2::Student::AcademicStatuses do
  let(:uid) { random_id }
  let(:user) { double(uid: uid) }
  let(:sis_student_academic_statuses_proxy) { double(get_inactive_completed: api_response)}
  let(:api_response) do
    {
      statusCode: status_code,
      feed: feed,
      studentNotFound: nil
    }
  end
  let(:status_code) { 200 }
  let(:academic_statuses) do
    [
      {
        'studentCareer' => {},
        'studentPlans' => [],
        'cumulativeGPA' => {},
        'cumulativeUnits' => {},
      }
    ]
  end
  let(:holds) { [] }
  let(:feed) do
    {
      'academicStatuses' => academic_statuses,
      'holds' => holds
    }
  end
  subject { described_class.new(user) }
  before do
    allow(HubEdos::StudentApi::V2::Feeds::AcademicStatuses).to receive(:new).with(user_id: uid).and_return(sis_student_academic_statuses_proxy)
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
      it 'returns array of HubEdos::StudentApi::V2::AcademicStatus objects' do
        result = subject.all
        expect(result.count).to eq 1
        expect(result.first).to be_an_instance_of HubEdos::StudentApi::V2::Student::AcademicStatus
      end
    end
  end
end
