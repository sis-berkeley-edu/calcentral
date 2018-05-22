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

  context 'when obtaining cs grading status' do
    let(:cs_grading_feed) do
      {
        statusCode: 200,
        feed: {
          ucSrClassGrading: {
            classGradingStatuses: {
              classGradingStatus: [
                cs_class_grading_status_1
              ]
            }
          }
        }
      }
    end

    let(:cs_class_grading_status_1) do
      {
        strm: semester_one_term_id,
        classNbr: '10001',
        courseTitle: 'MATH 101',
        classSection: '0001',
        classTitle: 'Some Math',
        ssrComponentCode: 'LEC',
        ssrComponent: 'Lecture',
        classType: 'E',
        classSectionAssociationId: '1',
        roster: grading_status_rosters
      }
    end
    let(:grading_status_rosters) do
      [
        midterm_roster,
        final_roster
      ]
    end
    let(:midterm_roster) do
      {
        gradeRosterTypeCode: 'MID',
        gradeRosterType: 'Mid-Term Grade',
        gradingStatusCode: 'GRD',
        gradingStatus: 'Grade Input Allowed',
        grApprovalStatusCode: 'APPR',
        grApprovalStatus: 'Approved',
        approvalDate: '2017-03-13',
        postingDate: nil,
        partialPost: 'N',
        overrideGradePoster: 'N'
      }
    end
    let(:final_roster) do
      {
        gradeRosterTypeCode: 'FIN',
        gradeRosterType: 'Final Grade',
        gradingStatusCode: 'POST',
        gradingStatus: 'Posted',
        grApprovalStatusCode: 'APPR',
        grApprovalStatus: 'Approved',
        approvalDate: nil,
        postingDate: '2017-05-19',
        partialPost: 'N',
        overrideGradePoster: 'N'
      }
    end

    before { allow_any_instance_of(CampusSolutions::Grading).to receive(:get).and_return(cs_grading_feed) }

    describe '#get_cs_status' do
      let(:ccn) { '10001' }
      let(:term_id) { semester_one_term_id }
      let(:is_law) { false }
      let(:cs_status) { subject.get_cs_status(ccn, is_law, term_id) }
      context 'when grading status is present' do
        it 'returns grading status from feed' do
          expect(cs_status).to eq({ midpointStatus: 'APPR', finalStatus: 'POST' })
        end
      end
      context 'when grading feed not present' do
        let(:cs_grading_feed) { nil }
        it 'returns nil' do
          expect(cs_status).to eq nil
        end
      end
    end

    describe '#find_status_in_rosters' do
      let(:is_law) { false }
      let(:is_summer) { false }
      let(:status_in_roster) { subject.find_status_in_rosters(rosters, is_law, is_summer) }
      context 'when rosters is blank' do
        let(:rosters) { nil }
        it 'returns blank codes for both statuses' do
          expect(status_in_roster).to eq({midpointStatus: nil, finalStatus: nil})
        end
      end
      context 'when rosters is a single roster' do
        let(:rosters) { final_roster }
        it 'returns only the final status' do
          expect(status_in_roster).to eq({midpointStatus: nil, finalStatus: 'POST'})
        end
      end
      context 'when rosters is an array' do
        let(:rosters) { grading_status_rosters }
        context 'when processing grading roster status for law course' do
          let(:is_law) { true }
          it 'returns only the final status' do
            expect(status_in_roster).to eq({finalStatus: 'POST'})
          end
        end
        context 'when processing grading roster status for summer term courses' do
          let(:is_summer) { true }
          it 'returns only the final status' do
            expect(status_in_roster).to eq({finalStatus: 'POST'})
          end
        end
        context 'when processing grading roster status for non-law spring or fall courses' do
          it 'returns both statuses' do
            expect(status_in_roster).to eq({midpointStatus: 'APPR', finalStatus: 'POST'})
          end
        end
      end
    end
  end

  describe '#parse_cs_grading_status' do
    let(:cs_grading_status) do
      { midpointStatus: 'APPR', finalStatus: 'GRD' }
    end
    let(:is_law) { false }
    let(:is_summer) { false }
    let(:grading_status) { subject.parse_cs_grading_status(cs_grading_status, is_law, is_summer) }
    let(:cs_grading_status) { { midpointStatus: cs_midpoint_grading_status, finalStatus: cs_final_grading_status } }
    let(:cs_midpoint_grading_status) { 'APPR' }
    let(:cs_final_grading_status) { 'GRD' }
    context 'when cs status is not expected' do
      context 'when midpoint grading status is incorrect' do
        let(:cs_midpoint_grading_status) { 'XYU' }
        it 'returns response indicating no cs data' do
          expect(grading_status).to eq ({finalStatus: :noCsData,midpointStatus: :noCsData})
        end
      end
      context 'when final grading status is incorrect' do
        let(:cs_final_grading_status) { 'XYU' }
        it 'returns response indicating no cs data' do
          expect(grading_status).to eq ({finalStatus: :noCsData,midpointStatus: :noCsData})
        end
      end
    end
    context 'when cs status is valid' do
      context 'when status for law context ' do
        let(:is_law) { true }
        it 'returns status with appropriate final status symbol' do
          expect(grading_status[:finalStatus]).to eq :GRD
          expect(grading_status[:midpointStatus]).to_not eq :APPR
        end
      end
      context 'when grading for summer session' do
        let(:is_summer) { true }
        it 'returns status with appropriate final status symbol' do
          expect(grading_status[:finalStatus]).to eq :GRD
          expect(grading_status[:midpointStatus]).to_not eq :APPR
        end
      end
      context 'when grading for non-law non-summer context' do
        it 'returns status for both midpoint and final grading' do
          expect(grading_status[:finalStatus]).to eq :GRD
          expect(grading_status[:midpointStatus]).to eq :APPR
        end
        context 'when cs status for midpoint is RDY' do
          let(:cs_midpoint_grading_status) { 'RDY' }
          it 'returns appropriate midpoint status' do
            expect(grading_status[:midpointStatus]).to eq :NRVW
          end
        end
        context 'when cs status for midpoint is NRVW' do
          let(:cs_midpoint_grading_status) { 'NRVW' }
          it 'returns appropriate midpoint status' do
            expect(grading_status[:midpointStatus]).to eq :NRVW
          end
        end
      end
    end
  end

  describe '#parse_cc_grading_status' do
    let(:cs_grading_status) { 'GRD' }
    let(:is_law) { false }
    let(:is_midpoint) { false }
    let(:term_id) { semester_one_term_id }
    let(:section) { nil }
    let(:cc_grading_status) { subject.parse_cc_grading_status(cs_grading_status, is_law, is_midpoint, term_id, section) }

    context 'when cs grading session configuration present' do
      before { allow(subject).to receive(:cs_grading_session_config?).and_return(true) }
      context 'when section present' do
        let(:section) do
          {
            gradingPeriodStartDate: Time.parse('2018-01-10 00:00:00 UTC'),
            gradingPeriodEndDate: Time.parse('2018-02-15 00:00:00 UTC')
          }
        end
        let(:summer_grading_window) do
          {
            final_begin_date: section[:gradingPeriodStartDate],
            final_end_date: section[:gradingPeriodEndDate]
          }
        end
        it 'provides grading period status for summer grading window' do
          expect(subject).to receive(:find_grading_period_status).with(summer_grading_window, false).and_return(:afterGradingPeriod)
          expect(cc_grading_status).to eq :gradesOverdue
        end
      end
      context 'when section not present' do
        let(:grading_window) do
          {
            final_begin_date: Time.parse('2018-01-10 00:00:00 UTC'),
            final_end_date: Time.parse('2018-02-15 00:00:00 UTC')
          }
        end
        it 'provides grading period status for non-summer grading' do
          expect(subject).to receive(:get_grading_dates).with(term_id, :general).and_return(grading_window)
          expect(subject).to receive(:find_grading_period_status).with(grading_window, false).and_return(:afterGradingPeriod)
          expect(cc_grading_status).to eq :gradesOverdue
        end
      end
    end

    context 'when cs grading session configuration is not present' do
      before { allow(subject).to receive(:cs_grading_session_config?).and_return(false) }
      it 'returns cc grading status for grading period not set' do
        expect(cc_grading_status).to eq :periodStarted
      end
    end
  end

  describe '#get_grading_dates' do
    let(:grading_type) { :general }
    context 'when session id not specified' do
      let(:grading_dates) { subject.get_grading_dates(semester_one_term_id, grading_type) }
      it 'returns grading dates for session 1' do
        expect(grading_dates[:mid_term_begin_date]).to eq Date.parse('Mon, 05 Mar 2018')
        expect(grading_dates[:mid_term_end_date]).to eq Date.parse('Sun, 11 Mar 2018')
        expect(grading_dates[:final_begin_date]).to eq Date.parse('Mon, 26 Mar 2018')
        expect(grading_dates[:final_end_date]).to eq Date.parse('Wed, 16 May 2018')
      end
    end
    context 'when session id specified' do
      let(:semester_one_term_id) { '2185' }
      let(:session_id) { '3W' }
      let(:grading_dates) { subject.get_grading_dates(semester_one_term_id, grading_type, session_id) }
      it 'returns grading dates for session 1' do
        expect(grading_dates[:mid_term_begin_date]).to eq nil
        expect(grading_dates[:mid_term_end_date]).to eq nil
        expect(grading_dates[:final_begin_date]).to eq Date.parse('Mon, 06 Aug 2018')
        expect(grading_dates[:final_end_date]).to eq Date.parse('Wed, 15 Aug 2018')
      end
    end
  end

  describe '#find_grading_period_status' do
    let(:mid_term_begin_date) { Date.parse('Mon, 05 Mar 2018') }
    let(:mid_term_end_date) { Date.parse('Mon, 12 Mar 2018') }
    let(:final_begin_date) { Date.parse('Mon, 26 Mar 2018') }
    let(:final_end_date) { Date.parse('Wed, 16 May 2018') }
    let(:has_mid_term) { true }
    let(:is_midpoint) { false }
    let(:dates) do
      {
        mid_term_begin_date: mid_term_begin_date,
        mid_term_end_date: mid_term_end_date,
        final_begin_date: final_begin_date,
        final_end_date: final_end_date,
        hasMidTerm: has_mid_term
      }
    end
    # Daylight Times Savings in 2018 (PDT): Mar 11 - Nov 4
    let(:fake_date_time) { DateTime.parse('Tue, 1 Apr 2018 16:20:42 PDT') }
    let(:grading_period_status) { subject.find_grading_period_status(dates, is_midpoint) }
    before { allow(Settings.terms).to receive(:fake_now).and_return fake_date_time }

    context 'when status requested for midpoint test' do
      let(:is_midpoint) { true }
      context 'when midpoint grading open date not present' do
        let(:mid_term_begin_date) { nil }
        it 'returns grading period not set indicator' do
          expect(grading_period_status).to eq :gradingPeriodNotSet
        end
      end
      context 'when midpoint grading deadline date not present' do
        let(:mid_term_end_date) { nil }
        it 'returns grading period not set indicator' do
          expect(grading_period_status).to eq :gradingPeriodNotSet
        end
      end
      context 'when before midpoint grading period begins' do
        let(:fake_date_time) { DateTime.parse('Tue, 20 Feb 2018 19:38:05 PST') }
        it 'returns before grading period indicator' do
          expect(grading_period_status).to eq :beforeGradingPeriod
        end
      end
      context 'when midpoint grading period has begun and not ended' do
        let(:fake_date_time) { DateTime.parse('Mon, 5 Mar 2018 00:00:01 PST') }
        it 'returns in grading period indicator' do
          expect(grading_period_status).to eq :inGradingPeriod
        end
      end
      context 'before midpoint grading period has ended' do
        let(:fake_date_time) { DateTime.parse('Mon, 12 Mar 2018 11:59:58 PDT') }
        it 'returns in grading period indicator' do
          expect(grading_period_status).to eq :inGradingPeriod
        end
      end
      context 'when midpoint grading period has ended' do
        let(:fake_date_time) { DateTime.parse('Tue, 13 Mar 2018 00:00:01 PDT') }
        it 'returns after grading period indicator' do
          expect(grading_period_status).to eq :afterGradingPeriod
        end
      end
    end
    context 'when status requested for final test' do
      let(:is_midpoint) { false }
      context 'when final grading open date not present' do
        let(:final_begin_date) { nil }
        it 'returns grading period not set indicator' do
          expect(grading_period_status).to eq :gradingPeriodNotSet
        end
      end
      context 'when final grading deadline date not present' do
        let(:final_end_date) { nil }
        it 'returns grading period not set indicator' do
          expect(grading_period_status).to eq :gradingPeriodNotSet
        end
      end
      context 'when before final grading period begins' do
        let(:fake_date_time) { DateTime.parse('Sun, 25 Mar 2018 00:00:01 PDT') }
        it 'returns before grading period indicator' do
          expect(grading_period_status).to eq :beforeGradingPeriod
        end
      end
      context 'after final grading period has begun and not ended' do
        let(:fake_date_time) { DateTime.parse('Mon, 26 Mar 2018 00:00:01 PDT') }
        it 'returns in grading period indicator' do
          expect(grading_period_status).to eq :inGradingPeriod
        end
      end
      context 'before final grading period has ended' do
      let(:fake_date_time) { DateTime.parse('Wed, 16 May 2018 11:59:58 PDT') }
        it 'returns in grading period indicator' do
          expect(grading_period_status).to eq :inGradingPeriod
        end
      end
      context 'when final grading period has ended' do
        let(:fake_date_time) { DateTime.parse('Thu, 17 May 2018 00:00:00 PDT') }
        it 'returns after grading period indicator' do
          expect(grading_period_status).to eq :afterGradingPeriod
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
