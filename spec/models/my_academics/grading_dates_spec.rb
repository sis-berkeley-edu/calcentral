describe MyAcademics::GradingDates do
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

  context '.get_grading_dates' do
    it 'returns cs grading dates' do
      grading_dates = described_class.get_grading_dates
      expect(grading_dates.count).to eq 3
      grading_dates.each do |date_key, grading_date|
        expect(['2168','2172','2175'].include?(date_key)).to eq true
        grading_date.each do |type_key, grading_career_type|
          expect(['UGRD','GRAD','LAW'].include?(type_key)).to eq true
          grading_career_type.each do |session_key, grading_session_code|
            expect(['1','Q1','Q2','Q3','Q4'].include?(session_key)).to eq true
            expect(grading_session_code).to have_keys([:mid_term_begin_date, :mid_term_end_date, :final_begin_date, :final_end_date])
          end
        end
      end
    end

    it 'converts date/time objects to date objects' do
      grading_dates = described_class.get_grading_dates
      expect(grading_dates.count).to eq 3
      grading_dates.each do |date_key, grading_date|
        grading_date.each do |type_key, grading_career_type|
          grading_career_type.each do |session_key, grading_session_code|
            grading_session = grading_session_code
            [:mid_term_begin_date, :mid_term_end_date, :final_begin_date, :final_end_date].each do |test_date_key|
              expect(grading_session[test_date_key]).to be_an_instance_of Date if grading_session[test_date_key].present?
            end
          end
        end
      end
    end
  end

  context '.fetch' do
    it 'returns grading periods hash' do
      grading_dates = described_class.fetch
      expect(grading_dates.keys.sort).to eq ['2168', '2172', '2175']
      expect(grading_dates['2168'].keys).to eq ['UGRD', 'GRAD', 'LAW']
      expect(grading_dates['2172'].keys).to eq ['UGRD', 'GRAD', 'LAW']
      expect(grading_dates['2175'].keys).to eq ['LAW']
      expect(grading_dates['2175']['LAW'].keys).to eq ['Q1', 'Q2', 'Q3', 'Q4']
    end
  end
end
