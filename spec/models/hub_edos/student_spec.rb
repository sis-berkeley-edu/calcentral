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

  describe '#academic_level_description' do
    let(:term_id) { '2182' }
    let(:registration_academic_career_code) { 'GRAD' }
    let(:academic_levels) do
      [
        {'level' => {'description' => 'Beginning of Term Description'}, 'type' => {'code' => 'BOT'}},
        {'level' => {'description' => 'End of Term Description'}, 'type' => {'code' => 'EOT'}},
      ]
    end
    let(:registration) do
      {
        'term' => {'id' => term_id},
        'academicCareer' => {'code' => registration_academic_career_code},
        'academicLevels' => academic_levels
      }
    end
    before { allow(subject).to receive(:latest_term_registrations).and_return([registration]) }
    context 'when career code is not LAW' do
      let(:registration_academic_career_code) { 'UGRD' }
      it 'returns the beginning of term academic level description' do
        expect(subject.instance_eval { academic_level_description(latest_term_registrations[0]) }).to eq 'Beginning of Term Description'
      end
    end
    context 'when career code is LAW' do
      let(:registration_academic_career_code) { 'LAW' }
      it 'returns the end of term academic level description' do
        expect(subject.instance_eval { academic_level_description(latest_term_registrations[0]) }).to eq 'End of Term Description'
      end
    end
  end

  describe '#latest_term_registrations' do
    let(:student_registrations) do
      [
        {'term' => {'id' => '2182'}, 'academicCareer' => {'code' => 'UGRD'}},
        {'term' => {'id' => '2185'}, 'academicCareer' => {'code' => 'UGRD'}},
        {'term' => {'id' => '2188'}, 'academicCareer' => {'code' => 'UGRD'}},
      ]
    end
    let(:highest_registrations_term_id) { '2188' }
    before do
      allow(subject).to receive(:student_registrations).and_return(student_registrations)
      allow(subject).to receive(:highest_registrations_term_id).and_return(highest_registrations_term_id)
    end
    context 'when no registrations in student data' do
      let(:student_registrations) { [] }
      it 'returns empty array' do
        expect(subject.instance_eval { latest_term_registrations }).to eq []
      end
    end
    context 'when single registration for latest term' do
      let(:highest_registrations_term_id) { '2192' }
      let(:student_registrations) do
        [
          {'term' => {'id' => '2185'}, 'academicCareer' => {'code' => 'GRAD'}},
          {'term' => {'id' => '2192'}, 'academicCareer' => {'code' => 'GRAD'}},
          {'term' => {'id' => '2188'}, 'academicCareer' => {'code' => 'GRAD'}},
        ]
      end
      it 'returns the latest registration' do
        registrations = subject.instance_eval { latest_term_registrations }
        expect(registrations.count).to eq 1
        expect(registrations[0]['term']['id']).to eq '2192'
        expect(registrations[0]['academicCareer']['code']).to eq 'GRAD'
      end
    end
    context 'when multiple registrations for latest term' do
      let(:highest_registrations_term_id) { '2192' }
      let(:student_registrations) do
        [
          {'term' => {'id' => '2185'}, 'academicCareer' => {'code' => 'GRAD'}},
          {'term' => {'id' => '2188'}, 'academicCareer' => {'code' => 'GRAD'}},
          {'term' => {'id' => '2192'}, 'academicCareer' => {'code' => 'GRAD'}},
          {'term' => {'id' => '2192'}, 'academicCareer' => {'code' => 'LAW'}},
        ]
      end
      it 'returns both registrations' do
        registrations = subject.instance_eval { latest_term_registrations }
        expect(registrations.count).to eq 2
        expect(registrations[0]['term']['id']).to eq '2192'
        expect(registrations[1]['term']['id']).to eq '2192'
        expect(registrations[0]['academicCareer']['code']).to eq 'GRAD'
        expect(registrations[1]['academicCareer']['code']).to eq 'LAW'
      end
    end
    context 'when calling more than once' do
      it 'remembers its own response' do
        expect(subject).to receive(:student_registrations).twice.and_return(student_registrations)
        expect(subject.instance_eval { latest_term_registrations[0]['term']['id'] }).to eq '2188'
        expect(subject.instance_eval { latest_term_registrations[0]['term']['id'] }).to eq '2188'
      end
    end
  end

  describe '#highest_registrations_term_id' do
    before { allow(subject).to receive(:student_registrations).and_return(student_registrations) }
    context 'when registrations are not present' do
      let(:student_registrations) { [] }
      it 'returns nil' do
        expect(subject.instance_eval { highest_registrations_term_id }).to eq nil
      end
    end
    context 'when registrations are present' do
      let(:student_registrations) do
        [
          {'academicCareer' => {'code' => 'UGRD'}, 'term' => {'id' => '2152', 'name' => '2015 Spring'}},
          {'academicCareer' => {'code' => 'GRAD'}, 'term' => {'id' => '2168', 'name' => '2016 Fall'}},
          {'academicCareer' => {'code' => 'LAW'}, 'term' => {'id' => '2168', 'name' => '2016 Fall'}},
          {'academicCareer' => {'code' => 'UGRD'}, 'term' => {'id' => '2162', 'name' => '2016 Spring'}},
          {'academicCareer' => {'code' => 'UGRD'}, 'term' => {'id' => '2158', 'name' => '2015 Fall'}},
        ]
      end
      it 'returns highest term id' do
        expect(subject.instance_eval { highest_registrations_term_id }).to eq '2168'
      end
    end
  end

  describe '#student_data' do
    let(:student_feed) { {'registrations' => registrations_array} }
    let(:registrations_array) do
      [
        {'term' => {'id' => '2182'}},
        {'term' => {'id' => '2185'}},
        {'term' => {'id' => '2188'}},
      ]
    end
    let(:student_proxy) { double(:student_proxy, :get => student_api_response) }
    before { allow(HubEdos::V2::Student).to receive(:new).and_return(student_proxy) }
    it 'returns ihub student api v2 feed' do
      expect(subject.instance_eval { student_data[:feed].has_key?('registrations') }).to eq true
    end
  end
end
