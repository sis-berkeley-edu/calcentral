describe User::Academics::Registration do
  let(:term) { {'id' => '2198', 'name' => '2019 Fall'} }
  let(:academic_career) { {'code' => 'UGRD', 'description' => 'Undergraduate'} }
  let(:term_units_total) do
    {
      'type' => {'code' => 'Total', 'description' => 'Total Units'},
      'unitsEnrolled' => term_units_total_enrolled,
      'unitsTaken' => term_units_total_taken,
    }
  end
  let(:term_units_total_enrolled) { 12 }
  let(:term_units_total_taken) { 4 }
  let(:term_units_for_gpa) { {'type' => {'code' => 'For GPA', 'description' => 'Units For GPA'}} }
  let(:term_units_not_for_gpa) { {'type' => {'code' => 'Not For GPA', 'description' => 'Units Not For GPA'}} }
  let(:term_units) do
    [
      term_units_total,
      term_units_for_gpa,
      term_units_not_for_gpa,
    ]
  end
  let(:academic_levels) do
    [
      {
        'type' => {'code' => 'BOT', 'description' => 'Beginning of Term'},
        'level' => {'code' => 'P3', 'description' => 'Professional Year 2'}
      },
      {
        'type' => {'code' => 'EOT', 'description' => 'End of Term'},
        'level' => {'code' => 'P3', 'description' => 'Professional Year 3'}
      }
    ]
  end
  let(:data) do
    {
      'term' => term,
      'academicCareer' => academic_career,
      'termUnits' => term_units,
      'academicLevels' => academic_levels,
    }
  end
  subject { described_class.new(data) }

  describe '#term_id' do
    it 'returns term id' do
      expect(subject.term_id).to eq '2198'
    end
  end

  describe '#undergraduate?' do
    context 'when academic career is undergraduate' do
      let(:academic_career) { {'code' => 'UGRD', 'description' => 'Undergraduate'} }
      it 'returns true' do
        expect(subject.undergraduate?).to eq true
      end
    end
    context 'when academic career is not undergraduate' do
      let(:academic_career) { {'code' => 'GRAD', 'description' => 'Graduate'} }
      it 'returns false' do
        expect(subject.undergraduate?).to eq false
      end
    end
  end

  describe '#career_code' do
    it 'returns academic career code' do
      expect(subject.career_code).to eq 'UGRD'
    end
  end

  describe '#career_description' do
    it 'returns academic career description' do
      expect(subject.career_description).to eq 'Undergraduate'
    end
  end

  describe '#unit_totals' do
    it 'returns the total term units' do
      result = subject.unit_totals
      expect(result['type']['code']).to eq 'Total'
      expect(result['unitsEnrolled']).to eq 12
    end
    context 'when term units not present' do
      let(:term_units) { [] }
      it 'returns empty hash' do
        expect(subject.unit_totals).to eq({})
      end
    end
  end

  describe '#total_units_taken' do
    it 'returns total term units taken' do
      expect(subject.total_units_taken).to eq 4
    end
  end

  describe '#total_units_enrolled' do
    it 'returns total term units enrolled' do
      expect(subject.total_units_enrolled).to eq 12
    end
  end

  describe '#enrolled?' do
    context 'when no units taken or enrolled' do
      let(:term_units_total_enrolled) { 0 }
      let(:term_units_total_taken) { 0 }
      it 'returns false' do
        expect(subject.enrolled?).to eq false
      end
    end
    context 'when units taken but not enrolled' do
      let(:term_units_total_enrolled) { 0 }
      let(:term_units_total_taken) { 4 }
      it 'returns true' do
        expect(subject.enrolled?).to eq true
      end
    end
    context 'when units enrolled but not taken' do
      let(:term_units_total_enrolled) { 12 }
      let(:term_units_total_taken) { 0 }
      it 'returns true' do
        expect(subject.enrolled?).to eq true
      end
    end
  end

  describe '#academic_levels' do
    it 'returns academic level objects' do
      result = subject.academic_levels
      expect(result).to be_an_instance_of ::User::Academics::Levels
    end
  end

  describe '#preferred_level' do
    before do
      allow(subject).to receive(:career_code).and_return(career_code)
    end
    context 'when career code is not law' do
      let(:career_code) { 'GRAD' }
      it 'returns beginning of term level' do
        expect(subject.preferred_level.type_code).to eq 'BOT'
        expect(subject.preferred_level.description).to eq 'Professional Year 2'
      end
    end
    context 'when career code is law' do
      let(:career_code) { 'LAW' }
      it 'returns end of term level' do
        expect(subject.preferred_level.type_code).to eq 'EOT'
        expect(subject.preferred_level.description).to eq 'Professional Year 3'
      end
    end
  end
end
