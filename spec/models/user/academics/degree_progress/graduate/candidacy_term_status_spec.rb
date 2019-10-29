describe User::Academics::DegreeProgress::Graduate::CandidacyTermStatus do
  let(:candidacy_status_code) { 'G' }
  let(:data) do
    {
      'emplid' => '11667051',
      'acad_career' => 'GRAD',
      'acad_prog' => 'GACAD',
      'acad_plan' => '79249PHDG',
      'acad_sub_plan' => '79249SP09G',
      'candidacy_end_term' => '2198',
      'candidacy_status_code' => candidacy_status_code,
    }
  end
  let(:fall_2019_term) { double(to_english: 'Fall 2019', name: 'Fall', year: '2019', code: 'B')}
  before { allow(Berkeley::Terms).to receive(:find_by_campus_solutions_id).with('2198').and_return(fall_2019_term) }
  subject { described_class.new(data) }

  describe '#status_code' do
    let(:candidacy_status_code) { 'G' }
    it 'returns status code' do
      expect(subject.status_code).to eq 'G'
    end
  end

  describe '#academic_career_code' do
    it 'returns academic career code' do
      expect(subject.academic_career_code).to eq 'GRAD'
    end
  end

  describe '#academic_program_code' do
    it 'returns academic program code' do
      expect(subject.academic_program_code).to eq 'GACAD'
    end
  end

  describe '#academic_plan_code' do
    it 'returns academic plan code' do
      expect(subject.academic_plan_code).to eq '79249PHDG'
    end
  end

  describe '#end_term_code' do
    it 'returns end term code' do
      expect(subject.end_term_code).to eq '2198'
    end
  end

  describe '#end_term' do
    it 'returns berkeley term object for end term' do
      result = subject.end_term
      expect(result.name).to eq 'Fall'
      expect(result.year).to eq '2019'
      expect(result.code).to eq 'B'
    end
  end

  describe '#end_term_description' do
    it 'returns description for end term' do
      expect(subject.end_term_description).to eq 'Fall 2019'
    end
    context 'when berkeley term object not available' do
      before { allow(subject).to receive(:end_term).and_return(nil) }
      it 'returns nil' do
        expect(subject.end_term_description).to eq nil
      end
    end
  end

  describe '#candidacy_status_description' do
    context 'when candidacy status code is \'G\'' do
      let(:candidacy_status_code) { 'G' }
      it 'returns \'Good\'' do
        expect(subject.candidacy_status_description).to eq 'Good'
      end
    end

    context 'when candidacy status code is \'L\'' do
      let(:candidacy_status_code) { 'L' }
      it 'returns \'Lapsed\'' do
        expect(subject.candidacy_status_description).to eq 'Lapsed'
      end
    end

    context 'when candidacy status code is \'E\'' do
      let(:candidacy_status_code) { 'E' }
      it 'returns \'Extended\'' do
        expect(subject.candidacy_status_description).to eq 'Extended'
      end
    end

    context 'when candidacy status code is \'R\'' do
      let(:candidacy_status_code) { 'R' }
      it 'returns \'Reinstated\'' do
        expect(subject.candidacy_status_description).to eq 'Reinstated'
      end
    end

    context 'when candidacy status code is \'T\'' do
      let(:candidacy_status_code) { 'T' }
      it 'returns \'Terminated\'' do
        expect(subject.candidacy_status_description).to eq 'Terminated'
      end
    end

    context 'when candidacy status code is unknown' do
      let(:candidacy_status_code) { '$' }
      it 'returns \'Unknown\'' do
        expect(subject.candidacy_status_description).to eq 'Unknown'
      end
      it 'logs error' do
        expect(Rails.logger).to receive(:error).with('Unknown candidacy status code \'$\' for EMPLID 11667051 in term 2198')
        expect(subject.candidacy_status_description).to eq 'Unknown'
      end
    end
  end

  describe '#as_json' do
    it 'returns hash representation of term status' do
      result = subject.as_json
      expect(result[:academicCareerCode]).to eq 'GRAD'
      expect(result[:academicProgramCode]).to eq 'GACAD'
      expect(result[:academicPlanCode]).to eq '79249PHDG'
      expect(result[:statusDescription]).to eq 'Good'
      expect(result[:endTermDescription]).to eq 'Fall 2019'
    end
  end
end
