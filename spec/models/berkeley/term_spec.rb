describe Berkeley::Term do

  context 'CS SIS' do
    subject { Berkeley::Term.new.from_cs_api(cs_feed) }
    let(:as_of_date) { nil }
    let(:cs_feed) { HubTerm::Proxy.new(fake:true, temporal_position: temporal_position, as_of_date: as_of_date).get_term }
    context 'Summer Sessions' do
      let(:temporal_position) {HubTerm::Proxy::CURRENT_TERM}
      it 'parses the feed' do
        expect(subject.slug).to eq 'summer-2016'
        expect(subject.year).to eq 2016
        expect(subject.code).to eq 'C'
        expect(subject.name).to eq 'Summer'
        expect(subject.campus_solutions_id).to eq '2165'
        expect(subject.is_summer).to eq true
        expect(subject.classes_start).to eq Time.zone.parse('2016-05-23 00:00:00').to_datetime
        expect(subject.classes_end).to eq Time.zone.parse('2016-08-12 23:59:59').to_datetime
        expect(subject.instruction_end).to eq Time.zone.parse('2016-08-12 23:59:59').to_datetime
        expect(subject.grades_entered).to eq Time.zone.parse('2016-09-09 23:59:59').to_datetime
        expect(subject.start).to eq Time.zone.parse('2016-05-23 00:00:00').to_datetime
        expect(subject.end).to eq Time.zone.parse('2016-08-12 23:59:59').to_datetime
        expect(subject.to_english).to eq 'Summer 2016'
        expect(subject.legacy?).to be_truthy
        expect(subject.sis_current_term?).to be_truthy
        expect(subject.end_drop_add).to be_blank
        expect(subject.raw_source[0]['temporalPosition']).to eq 'Current'
      end
    end

    context 'Fall' do
      let(:temporal_position) {HubTerm::Proxy::NEXT_TERM}
      it 'parses the feed' do
        expect(subject.slug).to eq 'fall-2016'
        expect(subject.year).to eq 2016
        expect(subject.code).to eq 'D'
        expect(subject.name).to eq 'Fall'
        expect(subject.campus_solutions_id).to eq '2168'
        expect(subject.is_summer).to eq false
        expect(subject.classes_start).to eq Time.zone.parse('2016-08-24 00:00:00').to_datetime
        expect(subject.classes_end).to eq Time.zone.parse('2016-12-02 23:59:59').to_datetime
        expect(subject.final_exam_week_start).to eq Time.zone.parse('2016-12-12 23:59:59').to_datetime
        expect(subject.final_exam_cs_data_available).to eq Time.zone.parse('2016-10-21 23:59:59 -0800').to_datetime
        expect(subject.instruction_end).to eq Time.zone.parse('2016-12-09 23:59:59').to_datetime
        expect(subject.grades_entered).to eq Time.zone.parse('2017-01-13 23:59:59').to_datetime
        expect(subject.start).to eq Time.zone.parse('2016-08-17 00:00:00').to_datetime
        expect(subject.end).to eq Time.zone.parse('2016-12-16 23:59:59').to_datetime
        expect(subject.to_english).to eq 'Fall 2016'
        expect(subject.legacy?).to be_falsey
        expect(subject.sis_current_term?).to be_falsey
        expect(subject.end_drop_add).to be_present
        expect(subject.raw_source[0]['temporalPosition']).to eq 'Future'
      end
    end

    context 'Future Spring' do
      let(:temporal_position) {HubTerm::Proxy::NEXT_TERM}
      let(:as_of_date) {'2016-12-16'}
      it 'parses the feed' do
        expect(subject.slug).to eq 'spring-2017'
        expect(subject.year).to eq 2017
        expect(subject.code).to eq 'B'
        expect(subject.name).to eq 'Spring'
        expect(subject.campus_solutions_id).to eq '2172'
        expect(subject.is_summer).to eq false
        expect(subject.to_english).to eq 'Spring 2017'
        expect(subject.legacy?).to be_falsey
        expect(subject.sis_current_term?).to be_falsey
        expect(subject.end_drop_add).to be_blank
        expect(subject.raw_source[0]['temporalPosition']).to eq 'Future'
      end
    end
  end

  context 'legacy SIS' do
    subject {Berkeley::Term.new(db_row)}
    context 'Summer Sessions' do
      let(:db_row) {{
        'term_yr' => '2014',
        'term_cd' => 'C',
        'term_status' => 'CS',
        'term_status_desc' => 'Current Summer',
        'term_name' => 'Summer',
        'term_start_date' => Time.gm(2014, 5, 27),
        'term_end_date' => Time.gm(2014, 8, 15)
      }}
      its(:slug) {should eq 'summer-2014'}
      its(:year) {should eq 2014}
      its(:code) {should eq 'C'}
      its(:name) {should eq 'Summer'}
      its(:campus_solutions_id) {should eq '2145'}
      its(:is_summer) {should eq true}
      its(:legacy_sis_term_status) {should eq 'CS'}
      its(:classes_start) {should eq Time.zone.parse('2014-05-27 00:00:00').to_datetime}
      its(:classes_end) {should eq Time.zone.parse('2014-08-15 23:59:59').to_datetime}
      its(:instruction_end) {should eq Time.zone.parse('2014-08-15 23:59:59').to_datetime}
      its(:start) {should eq Time.zone.parse('2014-05-27 00:00:00').to_datetime}
      its(:end) {should eq Time.zone.parse('2014-08-15 23:59:59').to_datetime}
      its(:to_english) {should eq 'Summer 2014'}
    end
    context 'Fall' do
      let(:db_row) {{
        'term_yr' => '2014',
        'term_cd' => 'D',
        'term_status' => 'FT',
        'term_status_desc' => 'Future Term',
        'term_name' => 'Fall',
        'term_start_date' => Time.gm(2014, 8, 28),
        'term_end_date' => Time.gm(2014, 12, 12)
      }}
      its(:slug) {should eq 'fall-2014'}
      its(:year) {should eq 2014}
      its(:code) {should eq 'D'}
      its(:name) {should eq 'Fall'}
      its(:campus_solutions_id) {should eq '2148'}
      its(:is_summer) {should eq false}
      its(:legacy_sis_term_status) {should eq 'FT'}
      its(:classes_start) {should eq Time.zone.parse('2014-08-28 00:00:00').to_datetime}
      its(:classes_end) {should eq Time.zone.parse('2014-12-05 23:59:59').to_datetime}
      its(:instruction_end) {should eq Time.zone.parse('2014-12-12 23:59:59').to_datetime}
      its(:final_exam_week_start) {should eq Time.zone.parse('2014-12-15 23:59:59').to_datetime}
      its(:final_exam_cs_data_available) {should eq Time.zone.parse('2014-10-31 23:59:59 -0800').to_datetime}
      its(:start) {should eq Time.zone.parse('2014-08-21 00:00:00').to_datetime}
      its(:end) {should eq Time.zone.parse('2014-12-19 23:59:59').to_datetime}
      its(:to_english) {should eq 'Fall 2014'}
    end
    context 'Spring' do
      let(:db_row) {{
        'term_yr' => '2014',
        'term_cd' => 'B',
        'term_status' => 'CT',
        'term_status_desc' => 'Current Term',
        'term_name' => 'Spring',
        'term_start_date' => Time.gm(2014, 1, 21),
        'term_end_date' => Time.gm(2014, 5, 9)
      }}
      its(:slug) {should eq 'spring-2014'}
      its(:year) {should eq 2014}
      its(:code) {should eq 'B'}
      its(:name) {should eq 'Spring'}
      its(:campus_solutions_id) {should eq '2142'}
      its(:is_summer) {should eq false}
      its(:legacy_sis_term_status) {should eq 'CT'}
      its(:classes_start) {should eq Time.zone.parse('2014-01-21 00:00:00').to_datetime}
      its(:classes_end) {should eq Time.zone.parse('2014-05-02 23:59:59').to_datetime}
      its(:instruction_end) {should eq Time.zone.parse('2014-05-09 23:59:59').to_datetime}
      its(:final_exam_week_start) {should eq Time.zone.parse('2014-05-12 23:59:59').to_datetime}
      its(:final_exam_cs_data_available) {should eq Time.zone.parse('2014-03-28 23:59:59 -700').to_datetime}
      its(:start) {should eq Time.zone.parse('2014-01-14 00:00:00').to_datetime}
      its(:end) {should eq Time.zone.parse('2014-05-16 23:59:59').to_datetime}
      its(:to_english) {should eq 'Spring 2014'}
    end
  end

end
