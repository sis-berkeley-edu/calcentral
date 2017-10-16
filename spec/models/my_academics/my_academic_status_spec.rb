describe MyAcademics::MyAcademicStatus do

  describe '#get_feed_internal' do
    subject { described_class.new(random_id).get_feed_internal }

    context 'when AcademicStatus response is nil' do
      before do
        allow_any_instance_of(HubEdos::AcademicStatus).to receive(:get).and_return(nil)
      end
      it 'returns nil' do
        expect(subject).to be nil
      end
    end
    context 'when AcademicStatus response is empty' do
      before do
        allow_any_instance_of(HubEdos::AcademicStatus).to receive(:get).and_return({})
      end
      it 'returns an empty response' do
        expect(subject).to eq({})
      end
    end
    context 'when AcademicStatus response is populated' do
      before do
        fake_proxy = HubEdos::AcademicStatus.new(fake: true, user_id: '61889')
        allow(HubEdos::AcademicStatus).to receive(:new).and_return fake_proxy
      end
      it 'should successfully return a response' do
        expect(subject[:statusCode]).to eq 200
      end
    end
  end

  describe '#assign_roles' do
    subject { academic_statuses }
    before do
      described_class.new(random_id).assign_roles(academic_statuses)
    end
    let(:career) do
      {
        'academicCareer' => { 'code' => 'UGRD' }
      }
    end
    let(:plan) do
      {
        'academicPlan' => {
          'plan' => { 'code' => '25000FPFU' },
          'academicProgram' => program
        },
        'statusInPlan' => plan_status
      }
    end
    let(:program) do
      {
        'program' => { 'code' => 'UCLS' }
      }
    end

    context 'when academic_statuses is empty' do
      let(:academic_statuses) { [] }
      it 'does not assign roles' do
        expect(subject).to eq []
      end
    end
    context 'when student has no career, plan, or program' do
      let(:academic_statuses) { [ {} ] }
      it 'does not assign roles' do
        expect(subject).to eq [ {} ]
      end
    end
    context 'when plans list and career are nil' do
      let(:academic_statuses) do
        [
          {
            'studentCareer' => nil,
            'studentPlans' => nil
          }
        ]
      end
      it 'does not assign roles' do
        expect(subject.first['studentPlans']).to be nil
      end
    end
    context 'when plans list is empty' do
      let(:academic_statuses) do
        [
          { 'studentPlans' => [] }
        ]
      end
      it 'does not assign roles' do
        expect(subject.first['studentPlans']).to eq []
      end
    end
    context 'when student has inactive plan' do
      let(:plan_status) { { 'status' => { 'code' => 'CM' } } }
      let(:academic_statuses) do
        [
          {
            'studentPlans' => [ plan ]
          }
        ]
      end
      it 'does not assign roles' do
        expect(subject.first['studentPlans'].first[:role]).to be nil
      end
    end
    context 'when student has active plan-based, program-based, and career-based roles' do
      let(:plan_status) { { 'status' => { 'code' => 'AC' } } }
      let(:academic_statuses) do
        [
          {
            'studentCareer' => career,
            'studentPlans' => [ plan ]
          }
        ]
      end
      it 'assigns roles' do
        expect(subject.first['studentCareer'][:role]).to eq 'ugrd'
        expect(subject.first['studentPlans'].first[:role]).to eq 'fpf'
        expect(subject.first['studentPlans'].first['academicPlan']['academicProgram'][:role]).to eq 'lettersAndScience'
      end
    end
  end
end
