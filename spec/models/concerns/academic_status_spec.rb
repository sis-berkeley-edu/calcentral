describe Concerns::AcademicStatus do

  describe '#academic_statuses' do
    subject { described_class.academic_statuses(feed)}

    context 'when feed is nil' do
      let(:feed) { nil }
      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end
    context 'when student is nil' do
      let(:feed) do
        {
          feed: {
            'student'=> nil
          }
        }
      end
      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end
    context 'when feed contains academic statuses' do
      let(:feed) do
        {
          feed: {
            'student'=> {
              'academicStatuses'=> ['STATUS1', 'STATUS2', 'STATUS3']
            }
          }
        }
      end
      it 'returns an array of academic statuses' do
        expect(subject).to eq ['STATUS1', 'STATUS2', 'STATUS3']
      end
    end
  end

  describe '#careers' do
    subject { described_class.careers(statuses)}

    context 'when statuses is nil' do
      let(:statuses) { nil }
      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end
    context 'when statuses is empty' do
      let(:statuses) { [] }
      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end
    context 'when career is not populated' do
      let(:statuses) do
        [
          {},
          { 'foo'=> 'bar '},
          { 'studentCareer'=> nil },
          { 'studentCareer'=> {} },
          { 'studentCareer'=> { 'academicCareer' => nil } }
        ]
      end
      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end
    context 'when career is populated' do
      let(:statuses) do
        [
          { 'studentCareer'=> { 'academicCareer' => 'CAREER1' } },
          { 'studentCareer'=> { 'academicCareer' => 'CAREER1' } },
          { 'studentCareer'=> { 'academicCareer' => 'CAREER2' } },
        ]
      end
      it 'returns a list of careers, excluding duplicates' do
        expect(subject).to eq ['CAREER1', 'CAREER2']
      end
    end
  end

  describe '#newest_career' do
    subject { described_class.newest_career(statuses)}

    context 'when statuses is nil' do
      let(:statuses) { nil }
      it 'returns nil' do
        expect(subject).to be nil
      end
    end
    context 'when statuses is empty' do
      let(:statuses) { [] }
      it 'returns nil' do
        expect(subject).to be nil
      end
    end
    context 'when career is not populated or is malformed' do
      let(:statuses) do
        [
          {},
          { 'foo'=> 'bar' },
          { 'studentCareer'=> nil },
          { 'studentCareer'=> {} },
          { 'studentCareer'=> { 'academicCareer' => nil } }
        ]
      end
      it 'returns nil' do
        expect(subject).to be nil
      end
    end
    context 'when student has one career' do
      let(:statuses) do
        [
          { 'studentCareer'=> { 'academicCareer' => { 'fromDate'=> 1 } } }
        ]
      end
      it 'returns the one career' do
        expect(subject).to be
        expect(subject['fromDate']).to eq 1
      end
    end
    context 'when student has multiple careers' do
      let(:statuses) do
        [
          { 'studentCareer'=> { 'academicCareer' => { 'fromDate'=> 1 } } },
          { 'studentCareer'=> { 'academicCareer' => { 'fromDate'=> 2 } } },
          { 'studentCareer'=> { 'academicCareer' => { 'fromDate'=> 3 } } },
        ]
      end
      it 'returns the career with the most recent fromDate' do
        expect(subject).to be
        expect(subject['fromDate']).to eq 3
      end
    end
  end

  describe '#active?' do
    subject { described_class.active?(plan)}

    context 'when plan is nil' do
      let(:plan) { nil }
      it 'returns falsey' do
        expect(subject).to be_falsey
      end
    end
    context 'when plan status is not populated' do
      let(:plan) { {} }
      it 'returns falsey' do
        expect(subject).to be_falsey
      end
    end
    context 'when plan is active' do
      let(:plan) do
        { 'statusInPlan'=> { 'status'=> { 'code'=> 'AC' } } }
      end
      it 'returns true' do
        expect(subject).to eq true
      end
    end
    context 'when plan is not active' do
      let(:plan) do
        { 'statusInPlan'=> { 'status'=> { 'code'=> 'CM' } } }
      end
      it 'returns false' do
        expect(subject).to eq false
      end
    end
  end

  describe '#has_holds?' do
    subject { described_class.has_holds?(feed) }

    context 'when feed is nil' do
      let(:feed) { nil }
      it 'returns false' do
        expect(subject).to eq false
      end
    end
    context 'when feed is empty' do
      let(:feed) { {} }
      it 'returns false' do
        expect(subject).to eq false
      end
    end
    context 'when feed is present' do
      let(:feed) { { :feed=> { 'student' => { 'holds' => holds} } } }

      context 'when holds is nil' do
        let(:holds) { nil }
        it 'returns false' do
          expect(subject).to eq false
        end
      end
      context 'when holds is not an array' do
        let(:holds) { 'garbage' }
        it 'returns false' do
          expect(subject).to eq false
        end
      end
      context 'when student has no holds' do
        let(:holds) { [] }
        it 'returns false' do
          expect(subject).to eq false
        end
      end
      context 'when student has holds' do
        let(:holds) { [ 1 ] }
        it 'returns true' do
          expect(subject).to eq true
        end
      end
    end
  end
end
