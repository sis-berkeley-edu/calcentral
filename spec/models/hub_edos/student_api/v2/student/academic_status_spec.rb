describe HubEdos::StudentApi::V2::Student::AcademicStatus do
  let(:student_plans) do
    [
      {
        'academicPlan' => {},
        'statusInPlan' => {},
        'expectedGraduationTerm' => {},
        'primary' => false,
        'fromDate' => '2020-03-09',
      }
    ]
  end
  let(:student_career) { {} }
  let(:attributes) do
    {
      'studentCareer' => student_career,
      'studentPlans' => student_plans,
    }
  end
  subject { described_class.new(attributes) }

  describe '#student_career' do
    it 'return student career object' do
      expect(subject.student_career).to be_an_instance_of ::HubEdos::StudentApi::V2::Student::StudentCareer
    end
  end

  describe '#student_plans' do
    it 'return student plans object' do
      expect(subject.student_plans).to be_an_instance_of ::HubEdos::StudentApi::V2::Student::StudentPlans
    end
  end

  describe '#active_student_plans' do
    before { allow(subject).to receive(:student_plans).and_return(student_plans) }
    context 'when student plans provides active plans' do
      let(:student_plans) { double(active: ['active_plan_object']) }
      it 'returns active student plans' do
        expect(subject.active_student_plans.count).to eq 1
        expect(subject.active_student_plans.first).to eq 'active_plan_object'
      end
    end
    context 'when student plans provides nil' do
      let(:student_plans) { nil }
      before { allow(subject).to receive(:student_plans).and_return(student_plans) }
      it 'returns empty array' do
        expect(subject.active_student_plans).to eq []
      end
    end
  end

  describe '#completed_student_plans' do
    before { allow(subject).to receive(:student_plans).and_return(student_plans) }
    context 'when student plans are present' do
      let(:student_plans) { double(completed: ['completed_plan_object']) }
      it 'returns active student plans' do
        expect(subject.completed_student_plans.count).to eq 1
        expect(subject.completed_student_plans.first).to eq 'completed_plan_object'
      end
    end
    context 'when student plans provides nil' do
      let(:student_plans) { nil }
      it 'returns empty array' do
        expect(subject.completed_student_plans).to eq []
      end
    end
  end
end
