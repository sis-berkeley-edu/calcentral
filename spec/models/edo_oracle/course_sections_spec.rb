describe EdoOracle::CourseSections do

  let(:term_id) { '2168' }
  let(:section_id) { random_id }
  let(:proxy) { described_class.new term_id, section_id }
  subject { proxy.get_section_data }

  context 'translate location' do
    shared_examples 'an intelligent parser of EDO db \'location\'' do
      it 'should properly split \'location\' value' do
        meeting = {
          'location' => location
        }
        result = proxy.send :translate_location, meeting
        expect(result[:buildingName]).to eq building_name
        expect(result[:roomNumber]).to eq room_number
      end
    end
    it_should_behave_like 'an intelligent parser of EDO db \'location\'' do
      let(:location) { 'Pauley Ballroom' }
      let(:building_name) { 'Pauley Ballroom' }
      let(:room_number) { nil }
    end
    it_should_behave_like 'an intelligent parser of EDO db \'location\'' do
      let(:location) { 'Off Campus' }
      let(:building_name) { 'Off Campus' }
      let(:room_number) { nil }
    end
    it_should_behave_like 'an intelligent parser of EDO db \'location\'' do
      let(:location) { 'Internet/Online' }
      let(:building_name) { 'Internet/Online' }
      let(:room_number) { nil }
    end
    it_should_behave_like 'an intelligent parser of EDO db \'location\'' do
      let(:location) { '2195 Hearst 330C' }
      let(:building_name) { '2195 Hearst' }
      let(:room_number) { '330C' }
    end
    it_should_behave_like 'an intelligent parser of EDO db \'location\'' do
      let(:location) { 'Genetics & Plant Bio 104' }
      let(:building_name) { 'Genetics & Plant Bio' }
      let(:room_number) { '104' }
    end
    it_should_behave_like 'an intelligent parser of EDO db \'location\'' do
      let(:location) { 'Unit 3 Spens-Black 3' }
      let(:building_name) { 'Unit 3 Spens-Black' }
      let(:room_number) { '3' }
    end
    it_should_behave_like 'an intelligent parser of EDO db \'location\'' do
      let(:location) { 'Hearst Field Annex C57' }
      let(:building_name) { 'Hearst Field Annex' }
      let(:room_number) { 'C57' }
    end
  end

  shared_context 'an empty result set' do
    its([:instructors]) { should eq [] }
    its([:schedules]) { should eq(oneTime: [], recurring: []) }
  end

  context 'working EDO connection' do
    before do
      expect(EdoOracle::Queries).to receive(:get_section_meetings).with(term_id, section_id).and_return meetings
      expect(EdoOracle::Queries).to receive(:get_section_final_exam).with(term_id, section_id).and_return final_exams
      expect(EdoOracle::Queries).to receive(:get_section_instructors).with(term_id, section_id).and_return instructors
    end

    context 'no instructors or meetings found' do
      let(:instructors) { [] }
      let(:meetings) { [] }
      let(:final_exams) { [] }
      it_behaves_like 'an empty result set'
    end

    context 'meeting data' do
      let(:instructors) { [] }
      let(:final_exams) { [] }
      let(:meetings) do
        [
          {
            'location' => 'WHEELER 0233',
            'meeting_days' => 'MOWEFR',
            'meeting_start_time' => '09:30',
            'meeting_end_time' => '10:59',
            'meeting_start_date' => Time.parse('2016-08-24 00:00:00 UTC'),
            'meeting_end_date' => Time.parse('2016-12-09 00:00:00 UTC')
          },
          {
            'location' => 'Requested General Assignment',
            'meeting_days' => 'TUTH',
            'meeting_start_time' => '14:00',
            'meeting_end_time' => '14:59',
            'meeting_start_date' => Time.parse('2016-08-24 00:00:00 UTC'),
            'meeting_end_date' => Time.parse('2016-12-09 00:00:00 UTC')
          },
          {
            'location' => 'Midterm Exam',
            'meeting_days' => 'WE',
            'meeting_start_time' => '16:00',
            'meeting_end_time' => '17:59',
            'meeting_start_date' => Time.parse('2016-09-28 00:00:00 UTC'),
            'meeting_end_date' => Time.parse('2016-09-28 00:00:00 UTC')
          },
          {
            'location' => nil,
            'meeting_days' => nil,
            'meeting_start_time' => nil,
            'meeting_end_time' => nil,
            'meeting_start_date' => nil,
            'meeting_end_date' => nil
          }
        ]
      end
      it 'sorts recurring and one-time schedules, ignoring empty rows' do
        expect(subject[:schedules][:oneTime]).to have(1).items
        expect(subject[:schedules][:recurring]).to have(2).items
      end
      it 'translates one-time meetings' do
        expect(subject[:schedules][:oneTime][0][:date]).to eq 'W 9/28'
        expect(subject[:schedules][:oneTime][0][:time]).to eq '4:00P-5:59P'
      end
      it 'translates recurring schedules' do
        expect(subject[:schedules][:recurring][0][:schedule]).to eq 'MWF 9:30A-10:59A'
        expect(subject[:schedules][:recurring][1][:schedule]).to eq 'TuTh 2:00P-2:59P'
      end
      it 'translates space' do
        expect(subject[:schedules][:oneTime][0][:buildingName]).to eq 'Midterm Exam'
        expect(subject[:schedules][:oneTime][0][:roomNumber]).to be_blank
        expect(subject[:schedules][:recurring][0][:buildingName]).to eq 'WHEELER'
        expect(subject[:schedules][:recurring][0][:roomNumber]).to eq '233'
        expect(subject[:schedules][:recurring][1][:buildingName]).to eq 'Room not yet assigned'
        expect(subject[:schedules][:recurring][1][:roomNumber]).to be_blank
      end
    end

    context 'exam data' do
      let(:meetings) { [] }
      let(:instructors) { [] }
      let(:final_exams) do
        [
          {
            'term_id'=>'2168',
            'session_id'=>'1',
            'exam_type' => 'Y',
            'exam_date'=>Time.parse('2016-12-15 00:00:00 UTC'),
            'exam_start_time'=>Time.parse('1900-01-01 19:00:00 UTC'),
            'exam_end_time'=>Time.parse('1900-01-01 22:00:00 UTC'),
            'location'=>'Dwinelle 105',
          },
          {
            'term_id'=>'2168',
            'session_id'=>'1',
            'exam_type' => 'A',
            'exam_date'=>nil,
            'exam_start_time'=>nil,
            'exam_end_time'=>nil,
            'location'=>nil,
          }
        ]
      end
      it 'counts final_exams properly' do
        expect(subject[:final_exams].length).to eq 2
      end
      it 'translates time correctly' do
        expect(subject[:final_exams][0][:exam_date]).to eq Time.parse('2016-12-15 00:00:00 UTC')
      end
      it 'translates space correctly' do
        expect(subject[:final_exams][0][:location]).to eq 'Dwinelle 105'
        expect(subject[:final_exams][1][:location]).to eq nil
      end

    end

    context 'instructor data' do
      let(:instructors) do
        [
          {
            'ldap_uid' => '2040',
            'person_name' => 'Albertus Magnus',
            'grade_roster_access' => 'A',
            'role_code' => 'PI',
            'print_in_schedule' => 'Y'
          },
          {
            'ldap_uid' => '242881',
            'person_name' => 'Thomas Aquinas',
            'grade_roster_access' => 'A',
            'role_code' => 'TNIC',
            'print_in_schedule' => 'N'
          }
        ]
      end
      let(:meetings) { [] }
      let(:final_exams) { [] }
      it 'translates attributes' do
        expect(subject[:instructors]).to eq [
          {
            name: 'Albertus Magnus',
            role: 'PI',
            gradeRosterAccess: 'A',
            uid: '2040',
            printInSchedule: 'Y'
          },
          {
            name: 'Thomas Aquinas',
            role: 'TNIC',
            gradeRosterAccess: 'A',
            uid: '242881',
            printInSchedule: 'N'
          }
        ]
      end
    end
  end

  context 'EDO DB errors' do
    before do
      allow(Settings.edodb).to receive(:fake).and_return false
      allow_any_instance_of(ActiveRecord::ConnectionAdapters::JdbcAdapter).to receive(:select_all)
        .and_raise ActiveRecord::JDBCError, 'Primary key swiped by highwaymen'
    end
    it_behaves_like 'an empty result set'
    it 'logs errors' do
      expect(Rails.logger).to receive(:error).with(/JDBCError/).at_least :once
      subject
    end
  end
end
