describe User::Academics::DegreeProgress::Graduate::CandidacyTermStatuses do
  subject { described_class.new(user) }
  let(:uid) { '61889' }
  let(:user) { User::Current.new(uid) }
  let(:candidacy_term_statuses) do
    [
      {
        'emplid' => '11667051',
        'acad_career' => 'GRAD',
        'acad_prog' => 'GACAD',
        'acad_plan' => '79249PHDG',
        'acad_sub_plan' => '79249SP03G',
        'candidacy_end_term' => '2202',
        'candidacy_status_code' => 'G'
      }
    ]
  end
  let(:candidacy_term_statuses_cached) { double(get_feed: candidacy_term_statuses) }
  before { allow(User::Academics::DegreeProgress::Graduate::CandidacyTermStatusesCached).to receive(:new).and_return(candidacy_term_statuses_cached) }

  describe '#all' do
    it 'returns candidacy term statuses' do
      result = subject.all
      result.each do |status|
        expect(status).to be_an_instance_of User::Academics::DegreeProgress::Graduate::CandidacyTermStatus
      end
    end
  end
end
