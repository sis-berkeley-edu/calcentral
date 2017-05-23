describe MyAcademics::AcademicsModule do

  describe '#newest_career' do
    subject { described_class.newest_career statuses }

    let(:grad_career) do
      {
        'code' => 'GRAD',
        'description' => 'Graduate'
      }
    end
    let(:ugrd_career) do
      {
        'code' => 'UGRD',
        'description' => 'Undergraduate'
      }
    end

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
    context 'when student has only one status' do
      let(:statuses) do
        [
          {
            'studentCareer' => {
              'academicCareer' => grad_career,
              'fromDate' => '2017-01-10',
              'toDate' => '2022-08-01'
            },
          }
        ]
      end
      it 'returns the career' do
        expect(subject).to eq grad_career
      end
    end
    context 'when student has multiple statuses' do
      let(:earliest_date) { '2013-01-10' }
      let(:recent_date) { '2017-01-10' }
      let(:statuses) do
        [
          {
            'studentCareer' => {
              'academicCareer' => ugrd_career,
              'fromDate' => earliest_date,
              'toDate' => '2017-05-01'
            },
          },
          {
            'studentCareer' => {
              'academicCareer' => grad_career,
              'fromDate' => recent_date,
              'toDate' => '2022-08-01'
            },
          }
        ]
      end
      it 'returns the career with the most recent fromDate' do
        expect(subject).to eq grad_career
      end

      context 'when fromDate is missing' do
        let(:recent_date) { nil }
        it 'returns the career with a populated fromDate' do
          expect(subject).to eq ugrd_career
        end
      end
    end
  end
end
