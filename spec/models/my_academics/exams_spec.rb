describe MyAcademics::Exams do

  let(:uid) {rand(99999).to_s}
  before do
    allow(Settings.terms).to receive(:fake_now).and_return '2016-04-01'
  end

  ## TEST CLASSES

  # a class with recurring times
  let(:ug_class_recurring) do
    {
      :role => 'Student',:course_code => 'BIO ENG C131',:courseCatalog => '131',
      :sections => [
        {
          :is_primary_section => true,
          :final_exams => [],
          :schedules => {
            :recurring => [
              {:buildingName=>'LeConte',:roomNumber=>'251',:schedule=>'MWF 2:00P-2:59P'}
            ]
          }
        },
        {
          :is_primary_section => false,
          :final_exams => [],
          :schedules => {
            :recurring=>[
              {:buildingName=>'Etcheverry',:roomNumber=>'1111',:schedule=>'W 4:00P-5:29P'}
            ]
          }
        }
      ]
    }
  end

  # chem 3b course exception
  let(:chem_3b_ug_class) do
    {
      :role=>'Student',:course_code=>'CHEM 3B',:courseCatalog=>'3B',
      :sections=> [
        {
          :is_primary_section=>true,
          :final_exams => [],
          :schedules=> {
            :recurring=>[
              {:buildingName=>'Pimentel',:roomNumber=>'1',:schedule=>'MWF 2:00P-2:59P'}
            ]
          }
        }
      ]
    }
  end

  # a class with a waitlist and recurring
  let(:waitlist_recurring_ug_class) do
    {
      :role=>'Student',:course_code=>'COMPSCI 61B',:courseCatalog=>'61B',
      :sections=> [
        {
          :is_primary_section=>true,
          :final_exams => [],
          :schedules=>
            {
              :recurring=>[
                {:buildingName=>'Dwinelle',:roomNumber=>'155',:schedule=>'MWF 3:00P-3:59P'}
              ]
            },
          :waitlisted => true
        }
      ]
    }
  end

  # an ug class with nothing
  let(:no_recurring_ug_class) do
    {
      :role=>'Student',:course_code=>'EWMBA 107',:courseCatalog=>'107',
      :sections=>[
        {
          :is_primary_section=>true,
          :final_exams => [],
          :schedules=>
            {
              :recurring=>[]
            }
        }
      ]
    }
  end

  # a grad class with nothing
  let(:no_recurring_grad_class) do
    {
      :role=>'Student',:course_code=>'EWMBA 299',:courseCatalog=>'299',
      :sections=>[
        {
          :is_primary_section=>true,
          :final_exams => [],
          :schedules=>
            {
              :recurring=>[]
            }
        }
      ]
    }
  end

  # grad class and recurring
  let(:recurring_grad_class) do
    {
      :role=>'Student',:course_code=>'EWMBA 201B',:courseCatalog=>'201B',
      :sections=> [
        {
          :is_primary_section=>true,
          :final_exams => [],
          :schedules=>
            {
              :recurring=>[
                {:schedule=>'Sa 2:00P-6:00P'}
              ]
            }
        }
      ]
    }
  end

  # after parsed academic data, class with time
  let(:ug_class_time) do
    {:name => 'BIO ENG 131',:number => 131,:time => 'MWF 2:00P-2:59P',:waitlisted => nil}
  end

  # after parsed academic data, a course exception
  let(:ug_course_exception) do
    {:name => 'CHEM 3B',:number => 3,:time => 'MWF 2:00P-2:59P',:waitlisted => nil}
  end

  # after parsed academic data, a waitlisted class
  let(:waitlisted_class) do
    {:name => 'COMPSCI 61B',:number => 61,:time => 'MWF 3:00P-3:59P',:waitlisted => true}
  end

  # after parsed academic data, ug, nothing
  let(:ug_class_no_time) do
    {:name => 'EWMBA 107',:number => 107,:time => nil,:waitlisted => nil}
  end

  # after parsed academic data, grad, nothing
  let(:grad_class_no_time) do
    {:name => 'EWMBA 204',:number => 204,:time => nil,:waitlisted => nil}
  end

  # after parsed academic data, cs has exams
  let(:cs_class) do
    {
      :name => 'CHEM 3B',:number => 3,:time => 'MWF 2:00P-2:59P',:waitlisted => nil,
      :exam_location => 'Kroeber 221',
      :exam_date => 'Mon 12/12',
      :exam_time => '07:00PM',
      :exam_slot => Time.parse('2016-12-12 19:00:00')
    }
  end

  # after parsed academic data, cs still has no exams
  let(:no_cs_exam_class) do
    {
      :name => 'CHEM 3B',:number => 3,:time => 'MWF 2:00P-2:59P',:waitlisted => nil,
      :exam_location => 'No exam.',
      :exam_date => nil,
      :exam_time => nil,
      :exam_slot => 'none'
    }
  end

  # example exams with everything
  let(:all_exam) do
    {
      :location => 'Kroeber 221',
      :exam_type => 'Y',
      :exam_date => Time.parse('2016-12-12 00:00:00 UTC'),
      :exam_start_time=>Time.parse('1900-01-01 19:00:00 UTC'),
      :exam_end_time=>Time.parse('1900-01-01 22:00:00 UTC'),
    }
  end

  # example exam with an alternate method
  let(:alternate_exam) do
    {
      :location => nil,
      :exam_type => 'A',
      :exam_date => nil,
      :exam_start_time=> nil,
      :exam_end_time=>nil,
    }
  end

  # example exams with nothing
  let(:no_exam) do
    {
      :location => nil,
      :exam_type => 'Y',
      :exam_date => nil,
      :exam_start_time=> nil,
      :exam_end_time=> nil,
    }
  end

  ## TEST CLUSTERS

  let(:fall_2016_classes) do
    [
      ug_class_recurring,
      chem_3b_ug_class,
      waitlist_recurring_ug_class,
      no_recurring_ug_class,
      no_recurring_grad_class
    ]
  end

  let(:fall_2016_semester) do
    {
      :name=>'Fall 2016',:termCode=>'D',:termYear=>'2016',:timeBucket=>'future',:slug=>'fall-2016',
      :classes=> fall_2016_classes
    }
  end

  let(:summer_2016_semester) do
    {:name=>'Summer 2016',:termCode=>'C',:timeBucket=>'future'}
  end

  let(:fall_2015_semester) do
    {:name=>'Fall 2015',:termCode=>'D',:timeBucket=>'past'}
  end

  let(:spring_2016_semester) do
    {:name=>'Spring 2016',:termCode=>'B',:termYear=>'2016',:timeBucket=>'current',:slug=>'spring-2016',
     :classes=> [
        ug_class_recurring,
        chem_3b_ug_class,
        recurring_grad_class
      ]
    }
  end

  let(:fall_2016_exams_after_parsed) do
    {
      3 => [
        {
          :name => 'CHEM 3B',:number => 3,:time => 'MWF 2:00P-2:59P',:waitlisted => nil,
          :exam_location => '',:exam_date => 'Mon 12/12',:exam_time => '3-6P',:exam_slot => 3
        }
      ],
      8 => [
        {
          :name => 'COMPSCI 61B',:number => 61,:time => 'MWF 3:00P-3:59P',:waitlisted => true,
          :exam_location => '',:exam_date => 'Tue 12/13',:exam_time => '7-10P',:exam_slot => 8
        }
      ],
      15 => [
        {
          :name => 'BIO ENG 131',:number => 131,:time => 'MWF 2:00P-2:59P',:waitlisted => nil,
          :exam_location => '',:exam_date => 'Thu 12/15',:exam_time => '3-6P',:exam_slot => 15
        }
      ]
    }
  end

  let(:spring_2016_exams_after_parsed) do
    {
      Time.parse('2016-12-12 19:00:00') => [
        {
          :name => 'BIO ENG 131',:number => 131,:time => 'MWF 2:00P-2:59P',:waitlisted => nil,
          :exam_location => 'Kroeber 221',
          :exam_date => 'Mon 12/12',
          :exam_time => '07:00PM',
          :exam_slot => Time.parse('2016-12-12 19:00:00')
        }
      ],
      'none' => [
        {
          :name => 'CHEM 3B',:number => 3,:time => 'MWF 2:00P-2:59P',:waitlisted => nil,
          :exam_location => 'No exam.',
          :exam_date => nil,
          :exam_time => nil,
          :exam_slot => 'none'
        },
        {
          :name => 'EWMBA 201B',:number => 201,:time => 'Sa 2:00P-6:00P',:waitlisted => nil,
          :exam_location => 'No exam.',
          :exam_date => nil,
          :exam_time => nil,
          :exam_slot => 'none'
        }
      ]
    }
  end

  let(:fall_2016_semester_after_parsed) do
    {
      :cs_data_available => false,:name => 'Fall 2016',:term => 'D',
      :term_year => '2016',:timeBucket => 'future',:slug=>'fall-2016',
      :courses => [
        ug_class_time,
        ug_course_exception,
        waitlisted_class,
        ug_class_no_time,
        grad_class_no_time
      ],
      :exams => fall_2016_exams_after_parsed
    }
  end

  let(:spring_2016_semester_after_parsed) do
    {
      :cs_data_available => true,:name => 'Spring 2016',:term => 'B',
      :term_year => '2016',:timeBucket => 'current',:slug=>'spring-2016',
      :courses => [
        cs_class,
        no_cs_exam_class
      ],
      :exams => spring_2016_exams_after_parsed
    }
  end

  let(:semesters) do
    [
      fall_2016_semester,
      summer_2016_semester,
      fall_2015_semester,
      spring_2016_semester
    ]
  end

  let(:feed) do
    {
      :collegeAndLevel=>
        {
          :careers=>['Undergraduate'],
          :isCurrent=>true
        },
      :semesters=> semesters
    }
  end

  subject do
    MyAcademics::Exams.new(uid)
  end

  let(:final_exam_logic) do
    Berkeley::FinalExamSchedule.fetch
  end

  let(:feed_after_parse_academic_data) do
    [
      fall_2016_semester_after_parsed,
      spring_2016_semester_after_parsed
    ]
  end

  let(:merged_result) do
    subject.merge(feed)
  end


  ## TEST CASES

  context 'as a student' do
    context 'with no semesters' do
      let(:semesters) { [] }

      it 'should parse academic data correctly' do
        result = subject.parse_academic_data(feed[:semesters])
        expect(result.length).to eq 0
      end
    end

    context 'with semesters and classes and no cs exams' do
      it 'should parse academic data correctly' do
        result = subject.parse_academic_data(feed[:semesters])
        expect(result.length).to eq 2
        fall_2016 = result[0]
        spring_2016 = result[1]
        expect(fall_2016[:cs_data_available]).to eq false
        expect(spring_2016[:cs_data_available]).to eq true

        fall_courses = result[0][:courses]
        spring_courses = result[1][:courses]

        expect(fall_courses.length).to eq 5
        fall_courses.each do |course|
          expect(course[:name]).to be
          expect(course[:number]).to_not eq 0
          expect(course[:exam_location]).to_not be
        end

        expect(spring_courses.length).to eq 3
        spring_courses.each do |course|
          expect(course[:name]).to be
          expect(course[:number]).to be
          expect(course[:exam_location]).to eq 'No exam.'
        end
      end

      it 'should assign exams correctly' do
        result = subject.assign_exams(feed_after_parse_academic_data, final_exam_logic)
        expect(result.length).to eq 2

        spring_exams = result[0][:exams]
        fall_exams = result[1][:exams]

        expect(spring_exams.length).to eq 2
        spring_exams.each do |exam_group, data|
          data.each do |course|
            expect(course[:exam_slot]).to eq exam_group
            case exam_group
            when Time.parse('2016-12-12 19:00:00')
              expect(course[:exam_date]).to eq 'Mon 12/12'
              expect(course[:exam_time]).to eq '07:00PM'
            when 'none'
              expect(course[:exam_date]).to_not be
              expect(course[:exam_time]).to_not be
              expect(course[:exam_location]).to eq 'No exam.'
            end
          end
        end

        expect(fall_exams.length).to eq 3
        fall_exams.each do |exam_group, data|
          data.each do |course|
            expect(course[:exam_slot]).to eq exam_group
            case exam_group
            when 3
              expect(course[:exam_date]).to eq 'Mon 12/12'
              expect(course[:exam_time]).to eq '3-6P'
            when 15
              expect(course[:exam_date]).to eq 'Thu 12/15'
              expect(course[:exam_time]).to eq '3-6P'
            end
          end
        end
      end

    end

    context 'with semesters and classes and cs exams' do
      let(:ug_class_recurring) do
        {
          :role => 'Student',:course_code => 'BIO ENG 131',:courseCatalog => '131',
          :sections => [
            {
              :is_primary_section => true,
              :final_exams => [all_exam],
              :schedules => {
                :recurring => [
                  {:buildingName=>'LeConte',:roomNumber=>'251',:schedule=>'MWF 2:00P-2:59P'}
                ]
              }
            }
          ]
        }
      end

      let(:no_recurring_ug_class) do
        {
          :role=>'Student',:course_code=>'EWMBA 107',:courseCatalog=>'107',
          :sections=>[
            {
              :is_primary_section=>true,
              :final_exams => [no_exam],
              :schedules=>
                {
                  :recurring=>[]
                }
            }
          ]
        }
      end

      let(:recurring_grad_class) do
        {
          :role=>'Student',:course_code=>'EWMBA 201B',:courseCatalog=>'201B',
          :sections=> [
            {
              :is_primary_section=>true,
              :final_exams => [no_exam],
              :schedules=>
                {
                  :recurring=>[
                    {:schedule=>'Sa 2:00P-6:00P'}
                  ]
                }
            }
          ]
        }
      end

      it 'should parse academic data correctly' do
        result = subject.parse_academic_data(feed[:semesters])
        fall_courses = result[0][:courses]
        spring_courses = result[1][:courses]

        expect(fall_courses.length).to eq 5
        expect(fall_courses[0][:exam_location]).to_not be
        expect(fall_courses[1][:exam_location]).to_not be

        expect(spring_courses.length).to eq 3
        expect(spring_courses[0][:exam_location]).to eq 'Kroeber 221'
        expect(spring_courses[0][:exam_date]).to eq 'Mon 12/12'
        expect(spring_courses[1][:exam_location]).to eq 'No exam.'
        expect(spring_courses[2][:exam_location]).to eq 'Location TBD'
      end
    end

    context 'with semesters and no classes' do
      let(:fall_2016_classes) { [] }

      it 'should parse academic data correctly' do
        result = subject.parse_academic_data(feed[:semesters])
        expect(result[0][:courses].length).to eq 0
        expect(result[1][:courses].length).to eq 3
      end
    end

    context 'with classes and no exams as cs data is populated' do
      let(:feed_after_parse_academic_data) do
        [{
          :cs_data_available => true,:name => 'Fall 2016',:term => 'D',:term_year => '2016',:timeBucket => 'future',
          :courses => [no_cs_exam_class]
        }]
      end

      it 'should assign exams correctly' do
        result = subject.assign_exams(feed_after_parse_academic_data, final_exam_logic)
        expect(result[0][:exams].length).to eq 1
        result[0][:exams].each do |exam_slot, data|
          expect(exam_slot).to eq 'none'
        end
      end
    end

    it 'should not have any summer or past semesters' do
      merged_result.each do |semester|
        expect(semester[:term]).not_to eq('C')
        expect(semester[:timeBucket]).not_to eq('past')
      end
    end

    it 'should determine cs data is available correctly' do
      expect(subject.determine_cs_data_available(fall_2016_semester)).to eq false
      expect(subject.determine_cs_data_available(spring_2016_semester)).to eq true
    end

    it 'should determine the exam key correctly' do
      expect(subject.determine_exam_key(fall_2016_semester_after_parsed, ug_class_time, final_exam_logic)).to eq 'D-M-2:00P'
      expect(subject.determine_exam_key(fall_2016_semester_after_parsed, ug_course_exception, final_exam_logic)).to eq 'D-CHEM 3B'
      expect(subject.determine_exam_key(fall_2016_semester_after_parsed, ug_class_no_time, final_exam_logic)).to eq nil
      expect(subject.determine_exam_key(spring_2016_semester_after_parsed, cs_class, final_exam_logic)).to eq 'B-CHEM 3B'
    end

    it 'should determine the cs exam date correctly' do
      expect(subject.determine_exam_date(fall_2016_semester_after_parsed, 'Monday')).to eq 'Mon 12/12'
      expect(subject.determine_exam_date(fall_2016_semester_after_parsed, 'Tuesday')).to eq 'Tue 12/13'
      expect(subject.determine_exam_date(spring_2016_semester_after_parsed, 'Monday')).to eq 'Mon 5/9'
    end

    it 'should parse cs exam dates properly' do
      expect(subject.parse_cs_exam_date(all_exam)).to eq 'Mon 12/12'
      expect(subject.parse_cs_exam_date(no_exam)).to eq nil
    end

    it 'should parse cs exam times properly' do
      expect(subject.parse_cs_exam_time(all_exam)).to eq '07:00PM-10:00PM'
      expect(subject.parse_cs_exam_time(no_exam)).to eq nil
    end

    it 'should create cs exam slots properly' do
      expect(subject.parse_cs_exam_slot(all_exam)).to eq Time.parse('2016-12-12 19:00:00')
      expect(subject.parse_cs_exam_slot(alternate_exam)).to eq 'none'
      expect(subject.parse_cs_exam_slot(no_exam)).to eq 'none'
    end

    it 'should choose cs exam locations properly' do
      expect(subject.choose_cs_exam_location(all_exam)).to eq 'Kroeber 221'
      expect(subject.choose_cs_exam_location(alternate_exam)).to eq 'Final exam information not available. Please consult instructors.'
      expect(subject.choose_cs_exam_location(no_exam)).to eq 'Location TBD'
    end

  end
end
