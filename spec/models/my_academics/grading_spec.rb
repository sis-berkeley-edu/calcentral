describe MyAcademics::Grading do

  subject { described_class.new(uid) }
  let(:uid) { '123456' }
  let(:my_academics_feed) do
    {
      :teachingSemesters => [
        semester_one
      ]
    }
  end
  let(:semester_one) do
    {
      name: 'Spring 2018',
      slug: 'spring-2018',
      termId: semester_one_term_id,
      termCode: semester_one_term_code,
      termYear: '2018',
      timeBucket: 'current',
      campusSolutionsTerm: true,
      gradingInProgress: nil,
      classes: semester_classes
    }
  end
  let(:semester_one_term_id) { '2182' }
  let(:semester_one_term_code) { 'B' }
  let(:semester_classes) do
    [
      {
        role: 'Instructor',
        slug: 'math-101',
        session_code: nil,
        course_code: 'MATH 101',
        dept: semester_classes_dept,
        courseCatalog: '101',
        course_id: 'math-101-2XXX-B',
        sections: [section_one, section_two]
      }
    ]
  end
  let(:semester_classes_dept) { 'MATH' }
  let(:section_one) do
    {
      ccn: '10001',
      instruction_format: 'LEC',
      is_primary_section: true,
      section_label: 'LEC 001',
      section_number: '001',
      topic_description: nil,
      units: nil,
      start_date: Time.parse('2018-01-10 00:00:00 UTC'),
      end_date: Time.parse('2018-02-15 00:00:00 UTC'),
      session_id: '1',
      enroll_limit: 20,
      waitlist_limit: 0,
      instructors: [],
      schedules: {oneTime: [], recurring: []},
      final_exams: [],
      courseCode: 'MATH 101'
    }
  end
  let(:section_two) do
    {
      ccn: '10002',
      instruction_format: 'LEC',
      is_primary_section: true,
      section_label: 'LEC 002',
      section_number: '002',
      topic_description: nil,
      units: nil,
      start_date: Time.parse('2018-02-10 00:00:00 UTC'),
      end_date: Time.parse('2018-03-15 00:00:00 UTC'),
      session_id: '1',
      enroll_limit: 20,
      waitlist_limit: 0,
      instructors: [],
      schedules: {oneTime: [], recurring: []},
      final_exams: [],
      courseCode: 'MATH 102'
    }
  end

  let(:edo_grading_dates) do
    {
      '2182' => {
        'GRAD' => {
          '1' => {
            mid_term_begin_date: Date.parse('Mon, 05 Mar 2018'),
            mid_term_end_date: Date.parse('Mon, 12 Mar 2018'),
            final_begin_date: Date.parse('Mon, 26 Mar 2018'),
            final_end_date: Date.parse('Wed, 16 May 2018'),
            hasMidTerm: true
          }
        },
        'LAW' => {
          '1' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 05 Mar 2018'),
            final_end_date: Date.parse('Wed, 06 Jun 2018'),
            hasMidTerm: false
          }
        },
        'UGRD' => {
          '1' => {
            mid_term_begin_date: Date.parse('Mon, 05 Mar 2018'),
            mid_term_end_date: Date.parse('Sun, 11 Mar 2018'),
            final_begin_date: Date.parse('Mon, 26 Mar 2018'),
            final_end_date: Date.parse('Wed, 16 May 2018'),
            hasMidTerm: true
          }
        }
      },
      '2185' => {
        'GRAD' => {
          '10W' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 06 Aug 2018'),
            final_end_date: Date.parse('Wed, 15 Aug 2018'),
            hasMidTerm: false
          },
          '3W' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 06 Aug 2018'),
            final_end_date: Date.parse('Wed, 15 Aug 2018'),
            hasMidTerm: false
          },
          '6W1' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 25 Jun 2018'),
            final_end_date: Date.parse('Wed, 04 Jul 2018'),
            hasMidTerm: false
          },
          '6W2' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 06 Aug 2018'),
            final_end_date: Date.parse('Wed, 15 Aug 2018'),
            hasMidTerm: false
          },
          '8W' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 06 Aug 2018'),
            final_end_date: Date.parse('Wed, 15 Aug 2018'),
            hasMidTerm: false
          }
        },
        'UGRD' => {
          '10W' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 06 Aug 2018'),
            final_end_date: Date.parse('Wed, 15 Aug 2018'),
            hasMidTerm: false
          },
          '3W' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 06 Aug 2018'),
            final_end_date: Date.parse('Wed, 15 Aug 2018'),
            hasMidTerm: false
          },
          '6W1' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 25 Jun 2018'),
            final_end_date: Date.parse('Wed, 04 Jul 2018'),
            hasMidTerm: false
          },
          '6W2' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 06 Aug 2018'),
            final_end_date: Date.parse('Wed, 15 Aug 2018'),
            hasMidTerm: false
          },
          '8W' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 06 Aug 2018'),
            final_end_date: Date.parse('Wed, 15 Aug 2018'),
            hasMidTerm: false
          }
        },
        'LAW' => {
          'Q1' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 04 Jun 2018'),
            final_end_date: Date.parse('Tue, 19 Jun 2018'),
            hasMidTerm: false
          },
          'Q2' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Sat, 09 Jun 2018'),
            final_end_date: Date.parse('Tue, 10 Jul 2018'),
            hasMidTerm: false
          },
          'Q3' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Mon, 02 Jul 2018'),
            final_end_date: Date.parse('Fri, 03 Aug 2018'),
            hasMidTerm: false
          },
          'Q4' => {
            mid_term_begin_date: nil,
            mid_term_end_date: nil,
            final_begin_date: Date.parse('Fri, 27 Jul 2018'),
            final_end_date: Date.parse('Tue, 28 Aug 2018'),
            hasMidTerm: false
          }}
      }
    }
  end
  let(:grading_info_links) do
    {
      :general => Links::Link.new({
        name: 'Assistance with Grading: General',
        url: 'http://example.berkeley.edu/final-grading/',
        description: 'Assistance with grading for general classes'
      }),
      :midterm => Links::Link.new({
        name: 'Assistance with Midpoint Grading: General',
        url: 'http://example.berkeley.edu/midterm-grading/',
        description: 'Assistance with mid-term grading for general classes'
      }),
      :law => Links::Link.new({
        name: 'Assistance with Grading: Law',
        url: 'https://www.law.berkeley.edu/grading/',
        description: 'Assistance with grading for Law classes'
      })
    }
  end

  before do
    allow(MyAcademics::GradingDates).to receive(:fetch).and_return(edo_grading_dates)
    allow(MyAcademics::GradingInfoLinks).to receive(:fetch).and_return(grading_info_links)
  end

  context 'when adding grading information links' do
    describe '#add_grading_information_links' do
      it 'adds general grading information link' do
        subject.add_grading_information_links(semester_one)
        expect(semester_one[:gradingAssistanceLink]).to eq 'http://example.berkeley.edu/final-grading/'
      end
      it 'adds midpoint grading information link' do
        subject.add_grading_information_links(semester_one)
        expect(semester_one[:gradingAssistanceLinkMidpoint]).to eq 'http://example.berkeley.edu/midterm-grading/'
      end
      context 'when law classes present' do
        before { semester_classes[0][:dept] = 'LAW' }
        it 'adds law grading information link' do
          subject.add_grading_information_links(semester_one)
          expect(semester_one[:gradingAssistanceLinkLaw]).to eq 'https://www.law.berkeley.edu/grading/'
        end
      end
      context 'when semester is for summer' do
        before do
          semester_one[:termId] = '2185'
          semester_one[:termCode] = 'C'
        end
        it 'omits midpoint grading information link' do
          subject.add_grading_information_links(semester_one)
          expect(semester_one.has_key?(:gradingAssistanceLinkMidpoint)).to eq false
        end
      end
    end
  end

  context 'when adding grading dates to semesters and summer sections' do

    describe '#add_grading_dates' do
      context 'when semester is not supported by campus solutions grading interface' do
        let(:semester_one_term_id) { '2142' }
        it 'performs no action' do
          expect(subject).to_not receive(:add_grading_dates_to_summer_classes)
          expect(subject).to_not receive(:add_grading_dates_general)
          expect(subject).to_not receive(:add_grading_dates_law)
          subject.add_grading_dates(semester_one, semester_one_term_id)
        end
      end
      context 'when semester term is supported by campus solutions grading interface' do
        context 'when a summer semester' do
          let(:semester_one_term_code) { 'C' }
          it 'delegates to summer classes method' do
            expect(subject).to receive(:add_grading_dates_to_summer_classes)
            expect(subject).to_not receive(:add_grading_dates_general)
            expect(subject).to_not receive(:add_grading_dates_law)
            subject.add_grading_dates(semester_one, semester_one_term_id)
          end
        end
        context 'when not a summer semester' do
          let(:semester_one_term_id) { '2182' }
          context 'when semester includes non-law dept (general) classes' do
            it 'delegates to general grading dates method' do
              expect(subject).to receive(:add_grading_dates_general)
              expect(subject).to_not receive(:add_grading_dates_law)
              subject.add_grading_dates(semester_one, semester_one_term_id)
            end
          end
          context 'when semester includes law dept classes' do
            let(:semester_classes_dept) { 'LAW' }
            it 'delegates to law grading dates method' do
              expect(subject).to_not receive(:add_grading_dates_general)
              expect(subject).to receive(:add_grading_dates_law)
              subject.add_grading_dates(semester_one, semester_one_term_id)
            end
          end
        end
      end
    end

  end

  describe '#get_grading_dates' do
    let(:term_id) { '2182' }
    let(:grading_type) { :general }
    let(:session_id) { '1' }
    let(:grading_dates) { subject.get_grading_dates(term_id, grading_type, session_id) }

    context 'when grading term not configured' do
      let(:term_id) { '2025' }
      it 'returns nil' do
        expect(grading_dates).to eq nil
      end
    end
    context 'when grading type fails to map to configured career code' do
      let(:grading_type) { :football_player }
      it 'returns nil' do
        expect(grading_dates).to eq nil
      end
    end
    context 'when grading session is not configured' do
      let(:session_id) { '2' }
      it 'returns nil' do
        expect(grading_dates).to eq nil
      end
    end
    context 'when grading type is general' do
      it 'returns grading periods hash' do
        expect(grading_dates[:mid_term_begin_date]).to eq Date.parse('Mon, 05 Mar 2018')
        expect(grading_dates[:mid_term_end_date]).to eq Date.parse('Sun, 11 Mar 2018')
        expect(grading_dates[:final_begin_date]).to eq Date.parse('Mon, 26 Mar 2018')
        expect(grading_dates[:final_end_date]).to eq Date.parse('Wed, 16 May 2018')
        expect(grading_dates[:hasMidTerm]).to eq true
      end
    end
    context 'when grading type is law' do
      let(:grading_type) { :law }
      it 'returns grading periods hash' do
        expect(grading_dates[:mid_term_begin_date]).to eq nil
        expect(grading_dates[:mid_term_end_date]).to eq nil
        expect(grading_dates[:final_begin_date]).to eq Date.parse('Mon, 05 Mar 2018')
        expect(grading_dates[:final_end_date]).to eq Date.parse('Wed, 06 Jun 2018')
        expect(grading_dates[:hasMidTerm]).to eq false
      end
    end
    context 'when session id not provided' do
      let(:grading_dates) { subject.get_grading_dates(term_id, grading_type) }
      it 'returns primary session grading periods' do
        expect(grading_dates[:mid_term_begin_date]).to eq Date.parse('Mon, 05 Mar 2018')
        expect(grading_dates[:mid_term_end_date]).to eq Date.parse('Sun, 11 Mar 2018')
        expect(grading_dates[:final_begin_date]).to eq Date.parse('Mon, 26 Mar 2018')
        expect(grading_dates[:final_end_date]).to eq Date.parse('Wed, 16 May 2018')
        expect(grading_dates[:hasMidTerm]).to eq true
      end
    end
  end

  describe '#cs_grading_term?' do
    it 'returns true when term is a CS supported grading term' do
      expect(subject.cs_grading_term?('2182')).to eq true
    end
    it 'returns false when term is not a CS supported grading term' do
      expect(subject.cs_grading_term?('2152')).to eq false
    end
  end

  describe '#cs_grading_session_config?' do
    let(:term_id) { '2182' }
    let(:acad_career_code) { 'UGRD' }
    let(:session_id) { '1' }
    let(:grading_configured) { subject.cs_grading_session_config?(term_id, acad_career_code, session_id) }
    context 'when term is not a CS supported grading term' do
      let(:term_id) { '2102' }
      it 'returns false' do
        expect(grading_configured).to eq false
      end
    end
    context 'when career term is not present in grading configuration' do
      let(:acad_career_code) { 'ABCD' }
      it 'returns false' do
        expect(grading_configured).to eq false
      end
    end
    context 'when session is not present in grading configuration' do
      let(:acad_career_code) { 'LAW' }
      let(:session_id) { 'Q5' }
      it 'returns false' do
        expect(grading_configured).to eq false
      end
    end
    context 'when term, career, and session are present in grading configuration' do
      it 'returns true' do
        expect(grading_configured).to eq true
      end
    end
  end
end
