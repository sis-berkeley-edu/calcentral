describe HubEdos::Student do
  let(:uid) { random_id }
  let(:student_api_response) { {:feed => student_feed} }
  let(:student_feed) { {'names' => []} }
  subject { described_class.new(uid) }

  describe '#max_terms_in_attendance' do
    let(:academic_statuses_array) { [academic_status_one] }
    let(:student_feed) { {'academicStatuses' => academic_statuses_array} }
    before { allow(subject).to receive(:student_data).and_return(student_api_response) }
    context 'when single status includes terms in attendance count' do
      let(:academic_status_one) { {'termsInAttendance' => 4} }
      it 'returns term in attendance integer' do
        expect(subject.max_terms_in_attendance).to eq 4
      end
    end
    context 'when multiple statuses include terms in attendance count' do
      let(:academic_status_one) { {'termsInAttendance' => 6} }
      let(:academic_status_two) { {'termsInAttendance' => 5} }
      let(:academic_statuses_array) { [academic_status_one, academic_status_two] }
      it 'returns highest term in attendance integer' do
        expect(subject.max_terms_in_attendance).to eq 6
      end
    end
    context 'when no statuses include terms in attendance counts' do
      let(:academic_status_one) { {} }
      it 'returns nil' do
        expect(subject.max_terms_in_attendance).to eq nil
      end
    end
  end

  describe '#student_academic_level' do
    let(:current_registration_hash) do
      {
        'academicCareer' => {'code' => registration_academic_career_code},
        'academicLevels' => generate_academic_levels('Junior', 'Senior')
      }
    end
    def generate_academic_levels(bot_level, eot_level)
      [
        {'level' => {'description' => bot_level}, 'type' => {'code' => 'BOT'}},
        {'level' => {'description' => eot_level}, 'type' => {'code' => 'EOT'}},
      ]
    end
    before { allow(subject).to receive(:current_registration).and_return(current_registration_hash) }
    context 'when career code is not LAW' do
      let(:registration_academic_career_code) { 'UGRD' }
      it 'returns the beginning of term academic level description' do
        expect(subject.student_academic_level).to eq 'Junior'
      end
    end
    context 'when career code is LAW' do
      let(:registration_academic_career_code) { 'LAW' }
      it 'returns the end of term academic level description' do
        expect(subject.student_academic_level).to eq 'Senior'
      end
    end
  end

  describe '#current_registration' do
    let(:student_feed) { {'registrations' => registrations_array} }
    let(:current_term_id) { '2182' }
    let(:registrations_array) do
      [
        {'term' => {'id' => '2182'}},
        {'term' => {'id' => '2185'}},
        {'term' => {'id' => '2188'}},
      ]
    end
    let(:berkeley_terms) do
      current_term = double(:current_term, :campus_solutions_id => current_term_id)
      double(:terms, :current => current_term)
    end
    before do
      allow(subject).to receive(:student_data).and_return(student_api_response)
      allow(Berkeley::Terms).to receive(:fetch).and_return(berkeley_terms)
    end
    context 'when registration is present for current term' do
      let(:current_term_id) { '2182' }
      it 'returns current term registration object' do
        expect(subject.instance_eval { current_registration['term']['id'] }).to eq '2182'
      end
    end
    context 'when registration is not present for current term' do
      let(:current_term_id) { '2192' }
      it 'return nil' do
        expect(subject.instance_eval { current_registration }).to eq nil
      end
    end
    context 'when calling more than once' do
      it 'remembers its own response' do
        expect(Berkeley::Terms).to receive(:fetch).once.and_return(berkeley_terms)
        expect(subject.instance_eval { current_registration['term']['id'] }).to eq '2182'
        expect(subject.instance_eval { current_registration['term']['id'] }).to eq '2182'
      end
    end

    describe '#student_data' do
      let(:student_proxy) { double(:student_proxy, :get => student_api_response) }
      before { allow(HubEdos::V2::Student).to receive(:new).and_return(student_proxy) }
      it 'returns ihub student api v2 feed' do
        expect(subject.instance_eval { student_data[:feed].has_key?('registrations') }).to eq true
      end
    end
  end
end
