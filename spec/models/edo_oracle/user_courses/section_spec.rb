describe EdoOracle::UserCourses::Section do
  let(:user) { double(:uid => '61889') }
  let(:is_primary) { 'true' }
  let(:base_row) do
    {
      'section_id' => '31483',
      'term_id' => '2202',
      'session_id' => '1',
      'course_title' => 'Constitutional Law',
      'course_title_short' => 'Constitutional Law',
      'dept_name' => 'LAW',
      'dept_code' => 'LAW',
      'course_career_code' => 'LAW',
      'primary' => is_primary,
      'section_num' => '003',
      'instruction_format' => 'LEC',
      'primary_associated_section_id' => '31483',
      'section_display_name' => 'LAW 220.6',
      'topic_description' => nil,
      'course_display_name' => 'LAW 220.6',
      'catalog_id' => '220.6',
      'catalog_root' => '220.6',
      'catalog_prefix' => nil,
      'catalog_suffix' => nil,
    }
  end
  let(:instructor_assignment_row_data) do
    {
      'cs_course_id' => '112237',
      'enroll_limit' => 36,
      'waitlist_limit' => 35,
      'start_date' => Date.parse('2020-01-13 00:00:00 UTC'),
      'end_date' => Date.parse('2020-05-01 00:00:00 UTC'),
    }
  end
  let(:enroll_status) { 'E' }
  let(:law_enrollment_row_data) do
    {
      'acad_career' => 'LAW',
      'units_taken_law' => 3,
      'rqmnt_designtn' => 'LW2',
    }
  end
  let(:waitlisted_enrollment_row_data) do
    {
      'enroll_status' => enroll_status,
      'waitlist_position' => 32,
      'enroll_limit' => 36,
      'drop_class_if_enrl' => '0',
      'last_enrl_dt_stmp' => 'JAN 20, 2020',
      'message_nbr' => '213',
      'uc_reason_desc' => 'Reserved Seats',
      'error_message_txt' => 'Available seats are reserved. Reserved seat requirement not met. Student not enrolled.',
      'uc_enrl_lastattmpt_time' => '06:52PM',
      'uc_enrl_lastattmpt_date' => 'JUN 03, 2020',
    }
  end
  let(:row) { base_row }
  subject { described_class.new(user, row) }

  its(:section_id) { should eq '31483' }
  its(:course_catalog_number) { should eq '31483' }
  its(:term_id) { should eq '2202' }
  its(:session_id) { should eq '1' }
  its(:instruction_format) { should eq 'LEC' }
  its(:primary_section?) { should eq true }
  its(:section_label) { should eq 'LEC 003' }
  its(:section_number) { should eq '003' }
  its(:topic_description) { should eq nil }

  context 'when section is a waitlisted enrollment' do
    let(:row) { base_row.merge(waitlisted_enrollment_row_data) }

    context 'when section is waitlisted' do
      let(:enroll_status) { 'W' }
      its(:waitlisted?) { should eq true }
    end

    context 'when section is not waitlisted' do
      let(:enroll_status) { 'E' }
      its(:waitlisted?) { should eq false }
    end
  end

  describe '#as_json' do
    let(:result) { subject.as_json }
    context 'when section is a primary section' do
      let(:is_primary) { 'true' }
      context 'when instructing section' do
        let(:row) { base_row.merge(instructor_assignment_row_data) }
        it 'include start date' do
          expect(result[:start_date]).to eq Date.parse('2020-01-13 00:00:00 UTC')
        end
        it 'includes end date' do
          expect(result[:end_date]).to eq Date.parse('2020-05-01 00:00:00 UTC')
        end
      end
      it 'includes session id' do
        expect(result[:session_id]).to eq '1'
      end
      it 'does not include associated primary id' do
        expect(result[:associated_primary_id]).to eq nil
      end
    end

    context 'when section is a secondary section' do
      let(:is_primary) { 'false' }
      it 'includes associated primary id' do
        expect(result[:associated_primary_id]).to eq '31483'
      end
      it 'does not include start date' do
        expect(result[:start_date]).to eq nil
      end
      it 'does not include end date' do
        expect(result[:end_date]).to eq nil
      end
      it 'does not include session id' do
        expect(result[:session_id]).to eq nil
      end
    end

    context 'when waitlist enrollment info present' do
      let(:row) { base_row.merge(waitlisted_enrollment_row_data) }
      context 'when section is waitlisted' do
        let(:enroll_status) { 'W' }
        it 'includes waitlisted enrollment data' do
          expect(result[:waitlisted]).to eq true
          expect(result[:waitlistPosition]).to eq 32
          expect(result[:enroll_limit]).to eq 36
          expect(result[:drop_class_if_enrl]).to eq '0'
          expect(result[:last_enrl_dt_stmp]).to eq 'JAN 20, 2020'
          expect(result[:message_nbr]).to eq '213'
          expect(result[:error_message_txt]).to eq 'Available seats are reserved. Reserved seat requirement not met. Student not enrolled.'
          expect(result[:uc_reason_desc]).to eq 'Reserved Seats'
          expect(result[:uc_enrl_lastattmpt_date]).to eq 'JUN 03, 2020'
          expect(result[:uc_enrl_lastattmpt_time]).to eq '06:52PM'
        end
      end
      context 'when section is not waitlisted' do
        let(:enroll_status) { 'E' }
        it 'does not include waitlisted enrollment data' do
          expect(result.has_key?(:waitlisted)).to eq false
          expect(result.has_key?(:waitlistPosition)).to eq false
          expect(result.has_key?(:enroll_limit)).to eq false
          expect(result.has_key?(:drop_class_if_enrl)).to eq false
          expect(result.has_key?(:last_enrl_dt_stmp)).to eq false
          expect(result.has_key?(:message_nbr)).to eq false
          expect(result.has_key?(:error_message_txt)).to eq false
          expect(result.has_key?(:uc_reason_desc)).to eq false
          expect(result.has_key?(:uc_enrl_lastattmpt_date)).to eq false
          expect(result.has_key?(:uc_enrl_lastattmpt_time)).to eq false
        end
      end
    end
    context 'when waitlist enrollment info not present' do
      let(:row) { base_row.merge(instructor_assignment_row_data) }
      it 'includes instructor enrollment and waitlist data' do
        expect(result[:enroll_limit]).to eq 36
        expect(result[:waitlist_limit]).to eq 35
      end
    end
  end

  context 'when section is law enrollment' do
    let(:row) { base_row.merge(law_enrollment_row_data) }
    let(:law_enrollment_row) do
      {
        'units_taken_law' => 3,
        'units_earned_law' => 3,
        'rqmnt_desg_descr' => 'Fulfills Skills Requirement'
      }
    end
    before { allow(EdoOracle::Queries).to receive(:get_law_enrollment).and_return(law_enrollment_row) }
    its(:requirements_designation) { should eq 'Fulfills Skills Requirement' }
    its(:requirements_designation_code) { should eq 'LW2' }
    describe '#as_json' do
      let(:result) { subject.as_json }
      it 'includes law enrollment data' do
        expect(result[:lawUnits]).to eq 3
        expect(result[:requirementsDesignation]).to eq 'Fulfills Skills Requirement'
      end
    end
  end

end
