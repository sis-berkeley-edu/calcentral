describe MyAcademics::Grading::Session do
  let(:raw_edo_data) do
    [
      {"acad_career" => "UGRD", "term_id" => "2168", "session_code" => "1", "mid_term_begin_date" => nil, "mid_term_end_date"=>nil, "final_begin_date" => Time.parse('2016-12-12 00:00:00 UTC'), "final_end_date" => Time.parse('2016-12-21 00:00:00 UTC')},
      {"acad_career" => "UGRD", "term_id" => "2172", "session_code" => "1", "mid_term_begin_date" => Time.parse('2017-03-06 00:00:00 UTC'), "mid_term_end_date" => Time.parse('2017-03-10 00:00:00 UTC'), "final_begin_date" => Time.parse('2017-03-27 00:00:00 UTC'), "final_end_date" => Time.parse('2017-05-26 00:00:00 UTC')},
      {"acad_career" => "GRAD", "term_id" => "2168", "session_code" => "1", "mid_term_begin_date" => nil, "mid_term_end_date"=>nil, "final_begin_date" => Time.parse('2016-12-12 00:00:00 UTC'), "final_end_date" => Time.parse('2016-12-21 00:00:00 UTC')},
      {"acad_career" => "GRAD", "term_id" => "2172", "session_code" => "1", "mid_term_begin_date" => Time.parse('2017-03-06 00:00:00 UTC'), "mid_term_end_date" => Time.parse('2017-03-10 00:00:00 UTC'), "final_begin_date" => Time.parse('2017-03-27 00:00:00 UTC'), "final_end_date"=> Time.parse('2017-05-26 00:00:00 UTC')},
      {"acad_career" => "LAW", "term_id" => "2168", "session_code" => "1", "mid_term_begin_date" => nil, "mid_term_end_date"=>nil, "final_begin_date" => Time.parse('2016-11-05 00:00:00 UTC'), "final_end_date" => Time.parse('2017-01-11 00:00:00 UTC')},
      {"acad_career" => "LAW", "term_id" => "2172", "session_code" => "1", "mid_term_begin_date" => nil, "mid_term_end_date"=>nil, "final_begin_date" => Time.parse('2017-02-20 00:00:00 UTC'), "final_end_date" => Time.parse('2017-06-07 00:00:00 UTC')},
      {"acad_career" => "LAW", "term_id" => "2175", "session_code" => "Q1", "mid_term_begin_date" => nil, "mid_term_end_date"=>nil, "final_begin_date" => Time.parse('2017-06-12 00:00:00 UTC'), "final_end_date" => Time.parse('2017-06-27 00:00:00 UTC')},
      {"acad_career" => "LAW", "term_id" => "2175", "session_code" => "Q2", "mid_term_begin_date" => nil, "mid_term_end_date"=>nil, "final_begin_date" => Time.parse('2017-07-03 00:00:00 UTC'), "final_end_date" => Time.parse('2017-07-18 00:00:00 UTC')},
      {"acad_career" => "LAW", "term_id" => "2175", "session_code" => "Q3", "mid_term_begin_date" => nil, "mid_term_end_date"=>nil, "final_begin_date" => Time.parse('2017-07-24 00:00:00 UTC'), "final_end_date" => Time.parse('2017-08-08 00:00:00 UTC')},
      {"acad_career" => "LAW", "term_id" => "2175", "session_code" => "Q4", "mid_term_begin_date" => nil, "mid_term_end_date"=>nil, "final_begin_date" => Time.parse('2017-08-14 00:00:00 UTC'), "final_end_date" => Time.parse('2017-08-30 00:00:00 UTC')},
    ]
  end
  before { allow(EdoOracle::Queries).to receive(:get_grading_dates).and_return(raw_edo_data) }

  describe '.get_session' do
    let(:semester_term_id) { '2172' }
    let(:acad_career_code) { 'UGRD' }

    let(:session) { described_class.get_session(semester_term_id, acad_career_code) }
    context 'when session id not specified' do
      it 'returns grading dates for session 1' do
        expect(session.session_code).to eq '1'
        expect(session.midterm_period.start_date).to eq Time.parse('2017-03-06 00:00:00 UTC')
        expect(session.midterm_period.due_date).to eq Time.parse('2017-03-10 00:00:00 UTC')
        expect(session.final_period.start_date).to eq Time.parse('2017-03-27 00:00:00 UTC')
        expect(session.final_period.due_date).to eq Time.parse('2017-05-26 00:00:00 UTC')
      end
    end

    context 'when session id does not match' do
      let(:semester_term_id) { '2152' }
      it 'returns nil' do
        expect(session).to eq nil
      end
    end

    context 'when session id specified' do
      let(:semester_term_id) { '2175' }
      let(:acad_career_code) { 'LAW' }
      let(:session_id) { 'Q3' }
      let(:session) { described_class.get_session(semester_term_id, acad_career_code, session_id) }
      it 'returns grading dates for session 1' do
        expect(session.session_code).to eq 'Q3'
        expect(session.midterm_period.start_date).to eq nil
        expect(session.midterm_period.due_date).to eq nil
        expect(session.final_period.start_date).to eq Time.parse('2017-07-24 00:00:00 UTC')
        expect(session.final_period.due_date).to eq Time.parse('2017-08-08 00:00:00 UTC')
      end
    end
  end

  describe '.grading_term_present?' do
    it 'returns true when grading term is present' do
      expect(described_class.grading_term_present?('2168')).to eq true
    end
    it 'returns false when grading term is not present' do
      expect(described_class.grading_term_present?('2148')).to eq false
    end
  end

  describe '.all_sessions' do
    it 'returns cs grading dates' do
      grading_sessions_hash = described_class.all_sessions
      expect(grading_sessions_hash.count).to eq 3
      grading_sessions_hash.each do |term_key, term_careers|
        expect(['2168','2172','2175'].include?(term_key)).to eq true
        term_careers.each do |career_key, term_career_sessions|
          expect(['UGRD','GRAD','LAW'].include?(career_key)).to eq true
          term_career_sessions.each do |session_key, session|
            expect(['1','Q1','Q2','Q3','Q4'].include?(session.session_code)).to eq true
            expect(session.class).to eq MyAcademics::Grading::Session
          end
        end
      end
    end
  end

  describe '.fetch' do
    it 'returns grading sessions' do
      grading_dates = described_class.fetch
      expect(grading_dates.keys.sort).to eq ['2168', '2172', '2175']
      expect(grading_dates['2168'].keys).to eq ['UGRD', 'GRAD', 'LAW']
      expect(grading_dates['2172'].keys).to eq ['UGRD', 'GRAD', 'LAW']
      expect(grading_dates['2175'].keys).to eq ['LAW']
      expect(grading_dates['2175']['LAW'].keys).to eq ['Q1', 'Q2', 'Q3', 'Q4']
    end
  end
end
