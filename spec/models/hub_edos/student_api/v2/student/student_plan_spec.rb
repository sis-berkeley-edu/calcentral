describe HubEdos::StudentApi::V2::Student::StudentPlan do
  let(:attributes) do
    {
      'academicPlan' => {
        'plan' => {},
        'type' => {},
        'cipCode' => '24.0102',
        'targetDegree' => {},
        'ownedBy' => {},
      },
      'statusInPlan' => {
        'status' => {},
        'action' => {},
      },
      'expectedGraduationTerm' => {
        'id' => '2242',
        'name' => '2024 Spring',
        'category' => {
          'code' => 'R',
          'description' => 'Regular Term'
        },
        'academicYear' => '2024',
        'beginDate' => '2024-01-01',
        'endDate' => '2024-05-15'
      },
      'primary' => false,
      'fromDate' => '2020-03-09',
    }
  end

  subject { described_class.new(attributes) }

  context 'when no attributes present' do
    let(:attributes) { nil }
    its(:academic_plan) { should eq nil }
    its(:status_in_plan) { should eq nil }
    its(:expected_graduation_term) { should eq nil }
    its(:primary) { should eq nil }
    its(:from_date) { should eq nil }
    describe '#to_json' do
      it 'returns json representation' do
        json_result = subject.to_json
        hash_result = JSON.parse(json_result)
        expect(hash_result).to eq({})
      end
    end
  end

  its(:academic_plan) { should be_an_instance_of HubEdos::StudentApi::V2::AcademicPolicy::AcademicPlan }
  its(:status_in_plan) { should be_an_instance_of HubEdos::StudentApi::V2::Student::StatusInPlan }
  its(:primary) { should eq false }
  its(:from_date) { should eq Date.parse('2020-03-09') }
  its(:expected_graduation_term) { should be_an_instance_of HubEdos::StudentApi::V2::Term::Term }

  describe '#active?' do
    before { allow(subject).to receive(:status_in_plan).and_return(status_in_plan) }
    context 'when status in plan not present' do
      let(:status_in_plan) { nil }
      it 'returns false' do
        expect(subject.active?).to eq false
      end
    end
    context 'when status in plan has status code \'AC\'' do
      let(:status_in_plan) { double(status_code: 'AC') }
      it 'returns true' do
        expect(subject.active?).to eq true
      end
    end
    context 'when status in plan does not have status code \'AC\'' do
      let(:status_in_plan) { double(status_code: 'DC') }
      it 'returns false' do
        expect(subject.active?).to eq false
      end
    end
  end

  describe '#completed?' do
    before { allow(subject).to receive(:status_in_plan).and_return(status_in_plan) }
    context 'when status in plan not present' do
      let(:status_in_plan) { nil }
      it 'returns false' do
        expect(subject.completed?).to eq false
      end
    end
    context 'when status in plan has status code \'CM\'' do
      let(:status_in_plan) { double(status_code: 'CM') }
      it 'returns true' do
        expect(subject.completed?).to eq true
      end
    end
    context 'when status in plan does not have status code \'CM\'' do
      let(:status_in_plan) { double(status_code: 'DC') }
      it 'returns false' do
        expect(subject.completed?).to eq false
      end
    end
  end

end
