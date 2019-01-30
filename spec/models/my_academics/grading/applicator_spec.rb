describe MyAcademics::Grading::Applicator do

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
        courseCareerCode: semester_classes_course_career_code,
        courseCatalog: '101',
        course_id: 'math-101-2XXX-B',
        sections: [section_one, section_two]
      }
    ]
  end
  let(:semester_classes_course_career_code) { 'UGRD' }
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
      instructors: section_one_instructors,
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
      instructors: section_two_instructors,
      schedules: {oneTime: [], recurring: []},
      final_exams: [],
      courseCode: 'MATH 102'
    }
  end
  let(:section_one_instructors) { [] }
  let(:section_two_instructors) { [] }

  let(:edo_grading_dates_array) do
    [
      edo_grading_session_2182_grad_1,
      {
        'acad_career' => 'LAW',
        'term_id' => '2182',
        'session_code' => '1',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-03-05 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-06-06 00:00:00 UTC')
      },
      {
        'acad_career' => 'UGRD',
        'term_id' => '2182',
        'session_code' => '1',
        'mid_term_begin_date' => Time.parse('2018-03-05 00:00:00 UTC'),
        'mid_term_end_date' => Time.parse('2018-03-11 00:00:00 UTC'),
        'final_begin_date' => Time.parse('2018-03-26 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-05-16 00:00:00 UTC')
      },
      {
        'acad_career' => 'GRAD',
        'term_id' => '2185',
        'session_code' => '10W',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-08-06 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-08-15 00:00:00 UTC')
      },
      {
        'acad_career' => 'GRAD',
        'term_id' => '2185',
        'session_code' => '3W',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-08-06 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-08-15 00:00:00 UTC')
      },
      {
        'acad_career' => 'GRAD',
        'term_id' => '2185',
        'session_code' => '6W1',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-06-25 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-07-04 00:00:00 UTC')
      },
      {
        'acad_career' => 'GRAD',
        'term_id' => '2185',
        'session_code' => '6W2',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-08-06 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-08-15 00:00:00 UTC')
      },
      {
        'acad_career' => 'GRAD',
        'term_id' => '2185',
        'session_code' => '8W',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-08-06 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-08-15 00:00:00 UTC')
      },
      {
        'acad_career' => 'UGRD',
        'term_id' => '2185',
        'session_code' => '10W',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-08-06 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-08-15 00:00:00 UTC')
      },
      {
        'acad_career' => 'UGRD',
        'term_id' => '2185',
        'session_code' => '3W',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-08-06 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-08-15 00:00:00 UTC')
      },
      {
        'acad_career' => 'UGRD',
        'term_id' => '2185',
        'session_code' => '6W1',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-06-25 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-07-04 00:00:00 UTC')
      },
      {
        'acad_career' => 'UGRD',
        'term_id' => '2185',
        'session_code' => '6W2',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-08-06 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-08-15 00:00:00 UTC')
      },
      {
        'acad_career' => 'UGRD',
        'term_id' => '2185',
        'session_code' => '8W',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-08-06 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-08-15 00:00:00 UTC')
      },
      {
        'acad_career' => 'LAW',
        'term_id' => '2185',
        'session_code' => 'Q1',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-06-04 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-06-19 00:00:00 UTC')
      },
      {
        'acad_career' => 'LAW',
        'term_id' => '2185',
        'session_code' => 'Q2',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-06-09 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-07-10 00:00:00 UTC')
      },
      {
        'acad_career' => 'LAW',
        'term_id' => '2185',
        'session_code' => 'Q3',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-07-02 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-08-03 00:00:00 UTC')
      },
      {
        'acad_career' => 'LAW',
        'term_id' => '2185',
        'session_code' => 'Q4',
        'mid_term_begin_date' => nil,
        'mid_term_end_date' => nil,
        'final_begin_date' => Time.parse('2018-07-27 00:00:00 UTC'),
        'final_end_date' => Time.parse('2018-08-28 00:00:00 UTC')
      },
    ]
  end
  let(:edo_grading_session_2182_grad_1) do
    {
      'acad_career' => 'GRAD',
      'term_id' => '2182',
      'session_code' => '1',
      'mid_term_begin_date' => Time.parse('2018-03-05 00:00:00 UTC'),
      'mid_term_end_date' => Time.parse('2018-03-12 00:00:00 UTC'),
      'final_begin_date' => Time.parse('2018-03-26 00:00:00 UTC'),
      'final_end_date' => Time.parse('2018-05-16 00:00:00 UTC')
    }
  end

  let(:grading_info_links) do
    {
      :general => {
        'name' => 'Assistance with Grading: General',
        'description' => 'Assistance with grading for general classes',
        'url' => 'http://example.berkeley.edu/final-grading/',
      },
      :midterm => {
        'name' => 'Assistance with Midpoint Grading: General',
        'description' => 'Assistance with mid-term grading for general classes',
        'url' => 'http://example.berkeley.edu/midterm-grading/',
      },
      :law => {
        'name' => 'Assistance with Grading: Law',
        'description' => 'Assistance with grading for Law classes',
        'url' => 'https://www.law.berkeley.edu/grading/',
      }
    }
  end

  before do
    allow(Settings.terms).to receive(:fake_now).and_return DateTime.parse('2018-08-10 12:00:00')
    allow(EdoOracle::Queries).to receive(:get_grading_dates).and_return(edo_grading_dates_array)
    allow(MyAcademics::Grading::InfoLinks).to receive(:fetch).and_return(grading_info_links)
  end

  context 'when adding grading information links' do
    describe '#add_grading_information_links' do
      context 'when undergraduate classes present' do
        let(:semester_classes_course_career_code) { 'UGRD' }
        it 'adds general grading information link' do
          subject.add_grading_information_links(semester_one)
          expect(semester_one[:gradingAssistanceLink]).to eq 'http://example.berkeley.edu/final-grading/'
        end
        it 'adds midpoint grading information link' do
          subject.add_grading_information_links(semester_one)
          expect(semester_one[:gradingAssistanceLinkMidpoint]).to eq 'http://example.berkeley.edu/midterm-grading/'
        end
      end
      context 'when graduate classes present' do
        let(:semester_classes_course_career_code) { 'GRAD' }
        it 'adds general grading information link' do
          subject.add_grading_information_links(semester_one)
          expect(semester_one[:gradingAssistanceLink]).to eq 'http://example.berkeley.edu/final-grading/'
        end
        it 'adds midpoint grading information link' do
          subject.add_grading_information_links(semester_one)
          expect(semester_one[:gradingAssistanceLinkMidpoint]).to eq 'http://example.berkeley.edu/midterm-grading/'
        end
      end
      context 'when law classes present' do
        let(:semester_classes_course_career_code) { 'LAW' }
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
            let(:semester_classes_course_career_code) { 'LAW' }
            it 'delegates to law grading dates method' do
              expect(subject).to_not receive(:add_grading_dates_general)
              expect(subject).to receive(:add_grading_dates_law)
              subject.add_grading_dates(semester_one, semester_one_term_id)
            end
          end
        end
      end
    end

    describe '#add_grading_dates_general' do
      let(:term_id) { '2182' }
      context 'when semester only includes undergraduate courses' do
        let(:semester_classes) { [{courseCareerCode: 'UGRD'}] }
        it 'merges only undergraduate grading dates into semester' do
          subject.add_grading_dates_general(semester_one, term_id)
          expect(semester_one[:gradingPeriodStartMidpoint]).to eq 'Mar 05'
          expect(semester_one[:gradingPeriodEndMidpoint]).to eq 'Mar 11'
          expect(semester_one[:gradingPeriodStartFinal]).to eq 'Mar 26'
          expect(semester_one[:gradingPeriodEndFinal]).to eq 'May 16'
        end
      end
      context 'when semester only includes graduate courses' do
        let(:semester_classes) { [{courseCareerCode: 'GRAD'}] }
        let(:edo_grading_session_2182_grad_1) do
          {
            'acad_career' => 'GRAD',
            'term_id' => '2182',
            'session_code' => '1',
            'mid_term_begin_date' => Time.parse('2018-03-12 00:00:00 UTC'),
            'mid_term_end_date' => Time.parse('2018-03-19 00:00:00 UTC'),
            'final_begin_date' => Time.parse('2018-04-02 00:00:00 UTC'),
            'final_end_date' => Time.parse('2018-04-16 00:00:00 UTC')
          }
        end

        it 'merges only graduate grading dates into semester' do
          subject.add_grading_dates_general(semester_one, term_id)
          expect(semester_one[:gradingPeriodStartMidpoint]).to eq 'Mar 12'
          expect(semester_one[:gradingPeriodEndMidpoint]).to eq 'Mar 19'
          expect(semester_one[:gradingPeriodStartFinal]).to eq 'Apr 02'
          expect(semester_one[:gradingPeriodEndFinal]).to eq 'Apr 16'
        end
      end
      context 'when semester includes both undergraduate and graduate courses' do
        let(:semester_classes) do
          [
            {courseCareerCode: 'UGRD'},
            {courseCareerCode: 'GRAD'},
          ]
        end
        context 'when midpoint grading dates are identical for UGRD and GRAD' do
          it 'provides general midpoint grading dates' do
            subject.add_grading_dates_general(semester_one, term_id)
            expect(semester_one[:gradingPeriodStartMidpoint]).to eq 'Mar 05'
            expect(semester_one[:gradingPeriodEndMidpoint]).to eq 'Mar 11'
            expect(semester_one[:gradingPeriodStartFinal]).to eq 'Mar 26'
            expect(semester_one[:gradingPeriodEndFinal]).to eq 'May 16'
          end
        end
        context 'when midpoint grading dates are different for UGRD and GRAD' do
          let(:edo_grading_session_2182_grad_1) do
            {
              'acad_career' => 'GRAD',
              'term_id' => '2182',
              'session_code' => '1',
              'mid_term_begin_date' => Time.parse('2018-03-12 00:00:00 UTC'),
              'mid_term_end_date' => Time.parse('2018-03-19 00:00:00 UTC'),
              'final_begin_date' => Time.parse('2018-03-26 00:00:00 UTC'),
              'final_end_date' => Time.parse('2018-05-16 00:00:00 UTC')
            }
          end
          it 'provides distinguished ugrd and grad midpoint grading dates' do
            subject.add_grading_dates_general(semester_one, term_id)
            expect(semester_one[:gradingPeriodStartMidpoint]).to eq 'Mar 05'
            expect(semester_one[:gradingPeriodEndMidpoint]).to eq 'Mar 11'
            expect(semester_one[:gradingPeriodStartMidpointGrad]).to eq 'Mar 12'
            expect(semester_one[:gradingPeriodEndMidpointGrad]).to eq 'Mar 19'
            expect(semester_one[:gradingPeriodStartFinal]).to eq 'Mar 26'
            expect(semester_one[:gradingPeriodEndFinal]).to eq 'May 16'
          end
        end
        context 'when final grading dates are identical for UGRD and GRAD' do
          let(:edo_grading_session_2182_grad_1) do
            {
              'acad_career' => 'GRAD',
              'term_id' => '2182',
              'session_code' => '1',
              'mid_term_begin_date' => Time.parse('2018-03-12 00:00:00 UTC'),
              'mid_term_end_date' => Time.parse('2018-03-19 00:00:00 UTC'),
              'final_begin_date' => Time.parse('2018-03-26 00:00:00 UTC'),
              'final_end_date' => Time.parse('2018-05-16 00:00:00 UTC')
            }
          end
          it 'provides general final grading dates' do
            subject.add_grading_dates_general(semester_one, term_id)
            expect(semester_one[:gradingPeriodStartMidpoint]).to eq 'Mar 05'
            expect(semester_one[:gradingPeriodEndMidpoint]).to eq 'Mar 11'
            expect(semester_one[:gradingPeriodStartFinal]).to eq 'Mar 26'
            expect(semester_one[:gradingPeriodEndFinal]).to eq 'May 16'
          end
        end
        context 'when final grading dates are different for UGRD and GRAD' do
          let(:edo_grading_session_2182_grad_1) do
            {
              'acad_career' => 'GRAD',
              'term_id' => '2182',
              'session_code' => '1',
              'mid_term_begin_date' => Time.parse('2018-03-05 00:00:00 UTC'),
              'mid_term_end_date' => Time.parse('2018-03-12 00:00:00 UTC'),
              'final_begin_date' => Time.parse('2018-04-02 00:00:00 UTC'),
              'final_end_date' => Time.parse('2018-04-16 00:00:00 UTC')
            }
          end
          it 'provides distinguished ugrd and grad final grading dates' do
            subject.add_grading_dates_general(semester_one, term_id)
            expect(semester_one[:gradingPeriodStartMidpoint]).to eq 'Mar 05'
            expect(semester_one[:gradingPeriodEndMidpoint]).to eq 'Mar 11'
            expect(semester_one[:gradingPeriodStartFinal]).to eq 'Mar 26'
            expect(semester_one[:gradingPeriodEndFinal]).to eq 'May 16'
            expect(semester_one[:gradingPeriodStartFinalGrad]).to eq 'Apr 02'
            expect(semester_one[:gradingPeriodEndFinalGrad]).to eq 'Apr 16'
          end
        end
      end
    end

    describe '#has_career_class?' do
      it 'returns true when class with career code is present' do
        expect(subject.has_career_class?('UGRD', semester_classes)).to eq true
      end
      it 'returns true when class with career code is NOT present' do
        expect(subject.has_career_class?('GRAD', semester_classes)).to eq false
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

  describe '#add_legacy_term_grading_to_classes' do
    context 'when instructor has grading access' do
      let(:section_one_instructors) { [{uid: uid, ccGradingAccess: :enterGrades}] }
      let(:section_two_instructors) { [{uid: uid, ccGradingAccess: :enterGrades}] }
      it 'adds grading link to class sections' do
        subject.add_legacy_term_grading_to_classes(semester_classes, semester_one_term_id)
        semester_classes[0][:sections].each do |section|
          expect(section[:gradingLink][:name]).to eq 'Grading'
          expect(section[:gradingLink][:urlId]).to eq 'UC_CX_TERM_GRD_LEGACY'
          expect(section[:gradingLink][:url]).to eq "https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/q/?ICAction=ICQryNameURL=PUBLIC.UCCS_R_BF_EGRD_INSTR&Parameters&BIND1=2182"
        end
      end
      it 'adds posted grading statuses to class sections' do
        subject.add_legacy_term_grading_to_classes(semester_classes, semester_one_term_id)
        semester_classes[0][:sections].each do |section|
          expect(section[:ccGradingStatus]).to eq :gradesPosted
        end
      end
    end
    context 'when instructor does not have grading access' do
      let(:section_one_instructors) { [{uid: uid, ccGradingAccess: :noGradeAccess}] }
      let(:section_two_instructors) { [{uid: uid, ccGradingAccess: :noGradeAccess}] }
      it 'does not add grading link to class sections' do
        subject.add_legacy_term_grading_to_classes(semester_classes, semester_one_term_id)
        semester_classes[0][:sections].each do |section|
          expect(section[:gradingLink]).to eq nil
        end
      end
      it 'does not add posted grading statuses to class sections' do
        subject.add_legacy_term_grading_to_classes(semester_classes, semester_one_term_id)
        semester_classes[0][:sections].each do |section|
          expect(section[:ccGradingStatus]).to eq nil
        end
      end
    end
  end

  describe '#add_legacy_class_grading_to_classes' do
    context 'when instructor has grading access' do
      let(:section_one_instructors) { [{uid: uid, ccGradingAccess: :enterGrades}] }
      let(:section_two_instructors) { [{uid: uid, ccGradingAccess: :enterGrades}] }
      it 'adds grading link to class sections' do
        subject.add_legacy_class_grading_to_classes(semester_classes, semester_one_term_id)
        semester_classes[0][:sections].each do |section|
          expect(section[:gradingLink][:name]).to eq 'Grading'
          expect(section[:gradingLink][:urlId]).to eq 'UC_CX_CRS_GRD_LEGACY'
          expect(section[:gradingLink][:url]).to eq "https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/q/?ICAction=ICQryNameURL=PUBLIC.UCCS_R_BF_EGRD_ROSTER_CC&BIND1=2182&BIND2=#{section[:ccn]}"
        end
      end
      it 'adds posted grading statuses to class sections' do
        subject.add_legacy_class_grading_to_classes(semester_classes, semester_one_term_id)
        semester_classes[0][:sections].each do |section|
          expect(section[:ccGradingStatus]).to eq :gradesPosted
        end
      end
    end
    context 'when instructor does not have grading access' do
      let(:section_one_instructors) { [{uid: uid, ccGradingAccess: :noGradeAccess}] }
      let(:section_two_instructors) { [{uid: uid, ccGradingAccess: :noGradeAccess}] }
      it 'does not add grading link to class sections' do
        subject.add_legacy_class_grading_to_classes(semester_classes, semester_one_term_id)
        semester_classes[0][:sections].each do |section|
          expect(section[:gradingLink]).to eq nil
        end
      end
      it 'does not add posted grading statuses to class sections' do
        subject.add_legacy_class_grading_to_classes(semester_classes, semester_one_term_id)
        semester_classes[0][:sections].each do |section|
          expect(section[:ccGradingStatus]).to eq nil
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
    let(:cs_grading_status) { :GRD }
    let(:is_law) { false }
    let(:is_midpoint) { false }
    let(:term_id) { semester_one_term_id }
    let(:section) { nil }
    let(:cc_grading_status) { subject.parse_cc_grading_status(cs_grading_status, is_law, is_midpoint, term_id, section) }

    context 'when cs grading session configuration present' do
      before { allow(subject).to receive(:cs_grading_session_config?).and_return(true) }
      let(:mock_grading_session) do
        double(:mock_grading_session)
      end
      context 'when section present' do
        let(:section) do
          {
            gradingPeriodStartDate: Time.parse('2018-01-10 00:00:00 UTC'),
            gradingPeriodEndDate: Time.parse('2018-02-15 00:00:00 UTC')
          }
        end
        it 'provides grading period status for summer grading window' do
          expect(cc_grading_status).to eq :gradesOverdue
        end
      end
      context 'when section not present' do
        context 'when after grading begins' do
          before do
            allow(MyAcademics::Grading::Session).to receive(:get_session).and_return(mock_grading_session)
            expect(subject).to receive(:find_grading_period_status).with(mock_grading_session, is_midpoint).and_return(:afterGradingPeriod)
          end
          it 'provides grading period status for non-summer grading' do
            expect(cc_grading_status).to eq :gradesOverdue
          end
        end
        context 'when before grading begins' do
          before do
            allow(MyAcademics::Grading::Session).to receive(:get_session).and_return(mock_grading_session)
            expect(subject).to receive(:find_grading_period_status).with(mock_grading_session, is_midpoint).and_return(:beforeGradingPeriod)
          end
          context 'when midterm grading status' do
            let(:is_midpoint) { true }
            context 'when not reviewed' do
              let(:cs_grading_status) { :NRVW }
              it 'returns period not started status' do
                expect(cc_grading_status).to eq :periodNotStarted
              end
            end
            context 'when approved' do
              let(:cs_grading_status) { :APPR }
              it 'returns grades posted status' do
                expect(cc_grading_status).to eq :gradesPosted
              end
            end
          end
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

  describe '#find_grading_period_status' do
    let(:mid_term_begin_date) { Date.parse('Mon, 05 Mar 2018') }
    let(:mid_term_end_date) { Date.parse('Mon, 12 Mar 2018') }
    let(:final_begin_date) { Date.parse('Mon, 26 Mar 2018') }
    let(:final_end_date) { Date.parse('Wed, 16 May 2018') }
    let(:is_midpoint) { false }
    let(:edo_hash) do
      {
        'term_id' => '2188',
        'session_code' => '1',
        'acad_career' => 'UGRD',
        'mid_term_begin_date' => mid_term_begin_date,
        'mid_term_end_date' => mid_term_end_date,
        'final_begin_date' => final_begin_date,
        'final_end_date' => final_end_date,
      }
    end
    let(:grading_session) { MyAcademics::Grading::Session.new({edo_hash: edo_hash}) }
    # Daylight Times Savings in 2018 (PDT): Mar 11 - Nov 4
    let(:fake_date_time) { DateTime.parse('Tue, 1 Apr 2018 16:20:42 PDT') }
    let(:grading_period_status) { subject.find_grading_period_status(grading_session, is_midpoint) }
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

  describe '#legacy_grading_term_type' do
    it 'returns :none when term is before spring 2001' do
      expect(subject.legacy_grading_term_type('1998')).to eq :none
      expect(subject.legacy_grading_term_type('2002')).to eq :none
      expect(subject.legacy_grading_term_type('2008')).to eq :none
    end
    it 'returns :legacy_term when term is spring 2001 to spring 2007' do
      expect(subject.legacy_grading_term_type('2012')).to eq :legacy_term
      expect(subject.legacy_grading_term_type('2015')).to eq :legacy_term
      expect(subject.legacy_grading_term_type('2018')).to eq :legacy_term
      expect(subject.legacy_grading_term_type('2055')).to eq :legacy_term
      expect(subject.legacy_grading_term_type('2072')).to eq :legacy_term
    end
    it 'returns :legacy_class when term is summer 2007 to summer 2016' do
      expect(subject.legacy_grading_term_type('2075')).to eq :legacy_class
      expect(subject.legacy_grading_term_type('2078')).to eq :legacy_class
      expect(subject.legacy_grading_term_type('2158')).to eq :legacy_class
      expect(subject.legacy_grading_term_type('2162')).to eq :legacy_class
      expect(subject.legacy_grading_term_type('2165')).to eq :legacy_class
    end
    it 'returns :cs when term is fall 2016 or after' do
      expect(subject.legacy_grading_term_type('2168')).to eq :cs
      expect(subject.legacy_grading_term_type('2172')).to eq :cs
      expect(subject.legacy_grading_term_type('2175')).to eq :cs
      expect(subject.legacy_grading_term_type('2178')).to eq :cs
      expect(subject.legacy_grading_term_type('2182')).to eq :cs
      expect(subject.legacy_grading_term_type('2192')).to eq :cs
    end
  end
end
