describe User::Academics::TermPlans::TermPlan do
  let(:data) do
    {
      'term_id' => '2198',
      'acad_career' => 'UGRD',
      'acad_career_descr' => 'Undergraduate',
      'acad_program' => 'UCLS',
      'acad_plan' => '25000U',
    }
  end
  subject { described_class.new(data) }

  describe '#term_id' do
    it 'returns term id' do
      expect(subject.term_id).to eq '2198'
    end
  end

  describe '#academic_career_code' do
    it 'returns academic career code' do
      expect(subject.academic_career_code).to eq 'UGRD'
    end
  end

  describe '#academic_career_description' do
    it 'returns academic career description' do
      expect(subject.academic_career_description).to eq 'Undergraduate'
    end
  end

  describe '#academic_program_code' do
    it 'returns academic program code' do
      expect(subject.academic_program_code).to eq 'UCLS'
    end
  end

  describe '#academic_plan_code' do
    it 'returns academic plan code' do
      expect(subject.academic_plan_code).to eq '25000U'
    end
  end

  describe '#as_json' do
    it 'returns the term plans in hash format' do
      result = subject.as_json
      expect(result[:termId]).to eq '2198'
      expect(result[:academicCareerCode]).to eq 'UGRD'
      expect(result[:academicCareerDescription]).to eq 'Undergraduate'
      expect(result[:academicProgramCode]).to eq 'UCLS'
      expect(result[:academicPlanCode]).to eq '25000U'
    end
  end
end
