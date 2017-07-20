describe MyAcademics::CollegeAndLevel do
  subject { MyAcademics::CollegeAndLevel.new(uid) }
  let(:uid) { '61889' }
  let(:campus_solutions_id) { '1234567890' }
  let(:legacy_campus_solutions_id) { '11667051' }
  let(:fake_spring_term) { double(is_summer: false, :year => 2015, :code => 'B') }
  let(:feed) { {}.tap { |feed| subject.merge feed } }

  # Hub Academic Status - Response / Feed
  let(:hub_academic_status_response) do
    {
      :statusCode => hub_academic_status_code,
      :feed => hub_academic_status_feed,
      :studentNotFound => nil
    }
  end
  let(:hub_academic_status_code) { 200 }
  let(:hub_academic_status_feed) do
    {
      "student" => {
        "academicStatuses" => hub_academic_statuses,
        "holds" => hub_holds,
        "awardHonors" => hub_award_honors,
        "degrees" => hub_degrees,
        "roles" => {
          'fpf' => false,
          'law' => false,
          'concurrent' => false,
          'haasFullTimeMba' => false,
          'haasEveningWeekendMba' => false,
          'haasExecMba' => false,
          'haasMastersFinEng' => false,
          'haasMbaPublicHealth' => false,
          'haasMbaJurisDoctor' => false,
          'ugrdUrbanStudies' => false,
          'summerVisitor' => false
        }
      }
    }
  end

  let(:hub_holds) do
    [
      {
        "amountRequired" => 0,
        "comments" => "",
        "contact" => {},
        "department" => {},
        "fromDate" => "2016-03-19",
        "fromTerm" => {},
        "impacts" => [],
        "reason" => {},
        "reference" => "",
        "type" => {}
      }
    ]
  end

  let(:hub_award_honors) do
    [
      {
        "awardDate" => '2012-10-14',
        "term" => {
          "id" => '2128'
        },
        "type" => {
          "code" => 'DEANS',
          "description" => 'Dean\'s List'
        }
      },
      {
        "awardDate" => '2013-04-14',
        "term" => {
          "id" => '2132'
        },
        "type" => {
          "code" => 'HONRDT',
          "description" => 'Honors to Date'
        }
      },
      {
        "awardDate" => '2012-10-14',
        "term" => {
          "id" => '2128'
        },
        "type" => {
          "code" => 'HONRDT',
          "description" => 'Honors to Date'
        }
      },
      {
        "awardDate" => '2013-04-14',
        "term" => {
          "id" => '2132'
        },
        "type" => {
          "code" => 'DEANS',
          "description" => 'Dean\'s List'
        }
      }

    ]
  end

  let(:hub_academic_statuses) { [hub_academic_status] }
  let(:hub_academic_status) do
    {
      "cumulativeGPA" => {},
      "cumulativeUnits" => [],
      "currentRegistration" => current_registration,
      "studentCareer" => {
        "academicCareer"=> academic_career
      },
      "studentPlans" => student_plans,
      "termsInAttendance" => 2
    }
  end

  let(:hub_degrees) { [hub_degree_awarded, hub_degree_not_awarded] }
  let(:hub_degree_awarded) do
    {
      'academicDegree' => {
        'type' => {
          'code' => 'MA',
          'description' => 'Master of Arts'
        }
      },
      'completionTerm' => {
        'id' => '2128',
        'name' => '2012 Fall',
        'category' => {
          'code' => 'R',
          'description' => 'Regular Term'
        },
        'academicYear' => '2013',
        'beginDate' => '2012-08-16',
        'endDate' => '2012-12-14'
      },
      'academicPlans' => [
        {
          'plan' => {
            'code' => '79249MAG',
            'description' => 'Education MA'
          }
        }
      ],
      'honors' => {},
      'dateAwarded' => '2012-12-14',
      'status' => {
        'code' => 'Awarded'
      },
      'statusDate' => '2015-12-12'
    }
  end
  let(:hub_degree_not_awarded) do
    {
      :academicDegree => {
        :type => {
          :code => 'PD',
          :description => 'Doctor of Philosophy'
        }
      },
      :completionTerm => {
        :name => '2010 Spring'
      },
      :academicPlans => [
        {
          :plan => {
            :code => '00345PHDG',
            :description => 'English PhD'
          }
        }
      ],
        :honors => {},
        :dateAwarded => '2010-05-14',
        :status => {
        :code => 'Not Awarded'
      },
      :statusDate => '2015-12-12'
    }
  end

  # Hub Academic Status - Current Registrations
  let(:current_registration) do
    {
      "academicCareer" => current_registration_academic_career,
      "academicLevel" => current_registration_academic_level,
      "term" => current_registration_term,
    }
  end
  let(:current_registration_academic_career) { undergraduate_academic_career }
  let(:current_registration_academic_level) { {"level" => { "code" => "30", "description" => "Junior" }} }
  let(:current_registration_term) { {"id"=>"2168", "name"=>"2016 Fall"} }

  # Hub Academic Status - Student / Academic Careers
  let(:academic_career) { undergraduate_academic_career }
  let(:undergraduate_academic_career) { { "code"=>"UGRD", "description"=>"Undergraduate" } }

  # Hub Academic Status - Student Plans (CPP)
  let(:student_plans) { [
    undergrad_student_plan_major,
    undergrad_student_plan_specialization,
    undergrad_student_plan_minor,
    grad_student_plan_designated_emphasis
  ] }
  let(:undergrad_student_plan_major) do
    hub_edo_academic_status_student_plan({
      career_code: 'UGRD',
      career_description: 'Undergraduate',
      program_code: 'UCLS',
      program_description: 'Undergrad Letters & Science',
      plan_code: '25345U',
      plan_description: 'English BA',
      role: 'default',
      enrollmentRole: 'default',
      admin_owners: [{org_code: 'ENGLISH', org_description: 'English', percentage: 100}],
      expected_grad_term_id: '2202',
      expected_grad_term_name: '2020 Spring'
    })
  end
  let(:undergrad_student_plan_specialization) do
    hub_edo_academic_status_student_plan({
      career_code: 'UGRD',
      career_description: 'Undergraduate',
      program_code: 'UCLS',
      program_description: 'Undergrad Letters & Science',
      plan_code: '25971U',
      plan_description: 'MCB-Cell & Dev Biology BA',
      role: 'default',
      enrollmentRole: 'default',
      type_code: 'SP',
      type_description: 'Major - UG Specialization',
      sub_plan_code: '25966SA02U',
      sub_plan_description: 'Biological Chemistry',
      admin_owners: [{org_code: 'MCELLBI', org_description: 'Molecular & Cell Biology', percentage: 100}],
      is_primary: false
    })
  end
  let(:undergrad_student_plan_minor) do
    hub_edo_academic_status_student_plan({
      career_code: 'UGRD',
      career_description: 'Undergraduate',
      program_code: 'UCLS',
      program_description: 'Undergrad Letters & Science',
      plan_code: '25090U',
      plan_description: 'Art BA',
      role: 'default',
      enrollmentRole: 'default',
      type_code: 'MIN',
      type_description: 'Major - UG Specialization',
      admin_owners: [{org_code: 'MCELLBI', org_description: 'Molecular & Cell Biology', percentage: 100}],
      is_primary: false
    })
  end

  let(:grad_student_plan_designated_emphasis) do
    hub_edo_academic_status_student_plan({
      career_code: 'GRAD',
      career_description: 'Graduate',
      program_code: 'GACAD',
      program_description: 'Graduate Academic Programs',
      plan_code: '00E017G',
      plan_description: 'Women, Gender and Sexuality DE',
      role: 'default',
      enrollmentRole: 'default',
      type_code: 'DE',
      type_description: 'Designated Emphasis',
      admin_owners: [{org_code: 'MCELLBI', org_description: 'Molecular & Cell Biology', percentage: 100}],
      is_primary: false
    })
  end
  let(:graduate_master_public_policy_plan) do
    hub_edo_academic_status_student_plan({
      career_code: 'GRAD',
      career_description: 'Graduate',
      program_code: 'GPRFL',
      program_description: 'Graduate Professional Programs',
      plan_code: '82790PPJDG',
      plan_description: 'Public Policy MPP-JD CDP',
      role: 'default',
      enrollmentRole: 'default',
      admin_owners: [
        {org_code: 'LAW', org_description: 'School of Law', percentage: 50},
        {org_code: 'PUBPOL', org_description: 'Goldman School Public Policy', percentage: 50},
      ]
    })
  end
  let(:law_jd_mpp_cdp_plan) do
    hub_edo_academic_status_student_plan({
      career_code: 'LAW',
      career_description: 'Law',
      program_code: 'LPRFL',
      program_description: 'Law Professional Programs',
      plan_code: '84501JDPPG',
      plan_description: 'Law JD-MPP CDP',
      role: 'law',
      enrollmentRole: 'law',
      admin_owners: [
        {org_code: 'LAW', org_description: 'School of Law', percentage: 50},
        {org_code: 'PUBPOL', org_description: 'Goldman School Public Policy', percentage: 50},
      ],
    })
  end
  let(:graduate_public_health_plan) do
    hub_edo_academic_status_student_plan({
      career_code: 'GRAD',
      career_description: 'Graduate',
      program_code: 'GPRFL',
      program_description: 'Graduate Professional Programs',
      plan_code: '96789PHBAG',
      plan_description: 'Public Health MPH-MBA CDP',
      admin_owners: [
        {org_code: 'BUS', org_description: 'Haas School of Business', percentage: 50},
        {org_code: 'PUBHEALTH', org_description: 'School of Public Health', percentage: 50},
      ]
    })
  end
  let(:graduate_business_admin_mba_haas_plan) do
    hub_edo_academic_status_student_plan({
      career_code: 'GRAD',
      career_description: 'Graduate',
      program_code: 'GPRFL',
      program_description: 'Graduate Professional Programs',
      plan_code: '70141BAPHG',
      plan_description: 'Business Admin MBA-MPH CDP',
      role: 'haasMbaPublicHealth',
      enrollmentRole: 'default',
      admin_owners: [
        {org_code: 'BUS', org_description: 'Haas School of Business', percentage: 50},
        {org_code: 'PUBHEALTH', org_description: 'School of Public Health', percentage: 50},
      ]
    })
  end

  before do
    allow_any_instance_of(CalnetCrosswalk::ByUid).to receive(:lookup_campus_solutions_id).and_return campus_solutions_id
    allow_any_instance_of(HubEdos::MyAcademicStatus).to receive(:get_feed).and_return hub_academic_status_response
  end

  context 'data sourcing' do
    it 'always queries hub data' do
      expect(feed[:collegeAndLevel][:statusCode]).to eq 200
    end
    context 'when hub response is present' do
      it 'sources from EDO Hub' do
        expect(feed[:collegeAndLevel][:level]).to eq 'Junior'
        expect(feed[:collegeAndLevel][:statusCode]).to eq 200
      end
    end

    context 'when hub response is empty' do
      let(:hub_academic_status_feed) { {} }
      let(:campus_solutions_id) { legacy_campus_solutions_id }
      context 'when current term is summer' do
        before { allow(subject).to receive(:current_term).and_return(double(is_summer: true)) }
        it 'sources from empty EDO Hub response' do
          expect(feed[:collegeAndLevel][:statusCode]).to eq 200
          expect(feed[:collegeAndLevel][:empty]).to eq true
          expect(feed[:collegeAndLevel][:isCurrent]).to eq true
          expect(feed[:collegeAndLevel][:termName]).to eq 'Fall 2013'
          expect(feed[:collegeAndLevel][:termId]).to eq nil
        end
      end
      context 'when current term is not summer' do
        before { allow(subject).to receive(:current_term).and_return(fake_spring_term) }
        it 'sources from empty EDO Hub response' do
          expect(feed[:collegeAndLevel][:empty]).to eq true
          expect(feed[:collegeAndLevel][:isCurrent]).to eq true
          expect(feed[:collegeAndLevel][:termName]).to eq 'Fall 2013'
          expect(feed[:collegeAndLevel][:termId]).to eq nil
        end
      end
    end
  end

  context 'when sourced from Hub academic status' do
    context 'failed response' do
      let(:failure_response) { {:errored=>true, :statusCode=>503, :body=>"An unknown server error occurred"} }
      before do
        allow_any_instance_of(HubEdos::MyAcademicStatus).to receive(:get_feed).and_return(failure_response)
      end
      it 'reports failure' do
        expect(feed[:collegeAndLevel][:statusCode]).to eq 503
        expect(feed[:collegeAndLevel][:empty]).to eq true
        expect(feed[:collegeAndLevel][:errored]).to eq true
        expect(feed[:collegeAndLevel][:body]).to eq "An unknown server error occurred"
      end
    end
    context 'undergrad with single academic status' do
      let(:has_law_role) { false }

      it 'reports success' do
        expect(feed[:collegeAndLevel][:statusCode]).to eq 200
      end

      it 'translates careers' do
        expect(feed[:collegeAndLevel][:careers]).to eq ['Undergraduate']
      end

      it 'translates level' do
        expect(feed[:collegeAndLevel][:level]).to eq 'Junior'
      end

      it 'translates terms in attendance' do
        expect(feed[:collegeAndLevel][:termsInAttendance]).to eq '2'
      end

      it 'includes the farthest graduation term available from all plans' do
        expect(feed[:collegeAndLevel][:lastExpectedGraduationTerm]).to eq({
          code: "2202",
          name: 'Spring 2020'
        })
      end

      it 'specifies term name' do
        expect(feed[:collegeAndLevel][:termName]).to eq 'Fall 2016'
      end

      it 'specifies term id' do
        expect(feed[:collegeAndLevel][:termId]).to eq '2168'
      end

      it 'translates minors' do
        expect(feed[:collegeAndLevel][:minors].first).to eq({
          college: 'Undergrad Letters & Science',
          minor: 'Art BA',
          subPlan: nil
        })
      end

      it 'translates majors' do
        expect(feed[:collegeAndLevel][:majors][0]).to eq({
          college: 'Undergrad Letters & Science',
          major: 'English BA',
          subPlan: nil
        })
        expect(feed[:collegeAndLevel][:majors][1]).to eq({
          college: 'Undergrad Letters & Science',
          major: 'MCB-Cell & Dev Biology BA',
          subPlan: 'Biological Chemistry'
        })
      end

      it 'translates plans' do
        expect(feed[:collegeAndLevel][:plans].count).to eq 4

        expect(feed[:collegeAndLevel][:plans][0][:career][:code]).to eq 'UGRD'
        expect(feed[:collegeAndLevel][:plans][0][:program][:code]).to eq 'UCLS'
        expect(feed[:collegeAndLevel][:plans][0][:plan][:code]).to eq '25345U'
        expect(feed[:collegeAndLevel][:plans][0][:expectedGraduationTerm][:code]).to eq '2202'
        expect(feed[:collegeAndLevel][:plans][0][:expectedGraduationTerm][:name]).to eq 'Spring 2020'
        expect(feed[:collegeAndLevel][:plans][0][:role]).to eq 'default'
        expect(feed[:collegeAndLevel][:plans][0][:enrollmentRole]).to eq 'default'
        expect(feed[:collegeAndLevel][:plans][0][:primary]).to eq true
        expect(feed[:collegeAndLevel][:plans][0][:type][:code]).to eq 'MAJ'
        expect(feed[:collegeAndLevel][:plans][0][:type][:category]).to eq 'Major'
        expect(feed[:collegeAndLevel][:plans][0][:college]).to eq 'Undergrad Letters & Science'

        expect(feed[:collegeAndLevel][:plans][1][:career][:code]).to eq 'UGRD'
        expect(feed[:collegeAndLevel][:plans][1][:program][:code]).to eq 'UCLS'
        expect(feed[:collegeAndLevel][:plans][1][:plan][:code]).to eq '25971U'
        expect(feed[:collegeAndLevel][:plans][1][:expectedGraduationTerm]).to eq nil
        expect(feed[:collegeAndLevel][:plans][1][:role]).to eq 'default'
        expect(feed[:collegeAndLevel][:plans][1][:enrollmentRole]).to eq 'default'
        expect(feed[:collegeAndLevel][:plans][1][:primary]).to eq false
        expect(feed[:collegeAndLevel][:plans][1][:type][:code]).to eq 'SP'
        expect(feed[:collegeAndLevel][:plans][1][:type][:category]).to eq 'Major'
        expect(feed[:collegeAndLevel][:plans][1][:college]).to eq 'Undergrad Letters & Science'

        expect(feed[:collegeAndLevel][:plans][2][:career][:code]).to eq 'UGRD'
        expect(feed[:collegeAndLevel][:plans][2][:program][:code]).to eq 'UCLS'
        expect(feed[:collegeAndLevel][:plans][2][:plan][:code]).to eq '25090U'
        expect(feed[:collegeAndLevel][:plans][2][:expectedGraduationTerm]).to eq nil
        expect(feed[:collegeAndLevel][:plans][2][:role]).to eq 'default'
        expect(feed[:collegeAndLevel][:plans][2][:enrollmentRole]).to eq 'default'
        expect(feed[:collegeAndLevel][:plans][2][:primary]).to eq false
        expect(feed[:collegeAndLevel][:plans][2][:type][:code]).to eq 'MIN'
        expect(feed[:collegeAndLevel][:plans][2][:type][:category]).to eq 'Minor'
        expect(feed[:collegeAndLevel][:plans][2][:college]).to eq 'Undergrad Letters & Science'

        expect(feed[:collegeAndLevel][:plans][3][:career][:code]).to eq 'GRAD'
        expect(feed[:collegeAndLevel][:plans][3][:program][:code]).to eq 'GACAD'
        expect(feed[:collegeAndLevel][:plans][3][:plan][:code]).to eq '00E017G'
        expect(feed[:collegeAndLevel][:plans][3][:expectedGraduationTerm]).to eq nil
        expect(feed[:collegeAndLevel][:plans][3][:role]).to eq 'default'
        expect(feed[:collegeAndLevel][:plans][3][:enrollmentRole]).to eq 'default'
        expect(feed[:collegeAndLevel][:plans][3][:primary]).to eq false
        expect(feed[:collegeAndLevel][:plans][3][:type][:code]).to eq 'DE'
        expect(feed[:collegeAndLevel][:plans][3][:type][:category]).to eq 'Designated Emphasis'
        expect(feed[:collegeAndLevel][:plans][3][:college]).to eq 'Graduate Academic Programs'
      end

      it 'translates sub-plans' do
        expect(feed[:collegeAndLevel][:plans][1][:subPlan]).to be
        expect(feed[:collegeAndLevel][:plans][1][:subPlan][:code]).to eq '25966SA02U'
        expect(feed[:collegeAndLevel][:plans][1][:subPlan][:description]).to eq 'Biological Chemistry'
      end

      it 'translates roles' do
        expect(feed[:collegeAndLevel][:roles]).to be
      end

      it 'translates holds' do
        expect(feed[:collegeAndLevel][:holds][:hasHolds]).to eq true
      end

      it 'translates degrees' do
        expect(feed[:collegeAndLevel][:degrees].count).to eq 1

        expect(feed[:collegeAndLevel][:degrees][0]['academicDegree']).to be
        expect(feed[:collegeAndLevel][:degrees][0]['academicDegree']['type']).to be
        expect(feed[:collegeAndLevel][:degrees][0]['academicDegree']['type']['code']).to eq 'MA'
        expect(feed[:collegeAndLevel][:degrees][0]['academicDegree']['type']['description']).to eq 'Master of Arts'

        expect(feed[:collegeAndLevel][:degrees][0]['completionTerm']).to be
        expect(feed[:collegeAndLevel][:degrees][0]['completionTerm']['id']).to eq '2128'
        expect(feed[:collegeAndLevel][:degrees][0]['completionTerm']['name']).to eq '2012 Fall'
        expect(feed[:collegeAndLevel][:degrees][0]['completionTerm']['category']).to be
        expect(feed[:collegeAndLevel][:degrees][0]['completionTerm']['category']['code']).to eq 'R'
        expect(feed[:collegeAndLevel][:degrees][0]['completionTerm']['category']['description']).to eq 'Regular Term'
        expect(feed[:collegeAndLevel][:degrees][0]['completionTerm']['academicYear']).to eq '2013'
        expect(feed[:collegeAndLevel][:degrees][0]['completionTerm']['beginDate']).to eq '2012-08-16'
        expect(feed[:collegeAndLevel][:degrees][0]['completionTerm']['endDate']).to eq '2012-12-14'

        expect(feed[:collegeAndLevel][:degrees][0]['academicPlans'].count).to eq 1
        expect(feed[:collegeAndLevel][:degrees][0]['academicPlans'][0]['plan']).to be
        expect(feed[:collegeAndLevel][:degrees][0]['academicPlans'][0]['plan']['code']).to eq '79249MAG'
        expect(feed[:collegeAndLevel][:degrees][0]['academicPlans'][0]['plan']['description']).to eq 'Education MA'

        expect(feed[:collegeAndLevel][:degrees][0]['honors']).to be
        expect(feed[:collegeAndLevel][:degrees][0]['dateAwarded']).to eq '2012-12-14'
        expect(feed[:collegeAndLevel][:degrees][0]['status']).to be
        expect(feed[:collegeAndLevel][:degrees][0]['status']['code']).to eq 'Awarded'
        expect(feed[:collegeAndLevel][:degrees][0]['statusDate']).to eq '2015-12-12'
      end
    end

    context 'when graduate student with multiple academic statuses' do
      # Hub Academic Statuses - Graduate with Grad / Law Joint Program
      let(:hub_academic_statuses) { [hub_academic_status, hub_academic_status_secondary] }
      let(:hub_academic_status_secondary) do
        {
          "cumulativeGPA" => {},
          "cumulativeUnits" => [],
          "currentRegistration" => current_registration_secondary,
          "studentCareer" => student_career_secondary,
          "studentPlans" => student_plans_secondary
        }
      end

      # Graduate Statuses - Current Registrations
      let(:current_registration_secondary) do
        {
          "academicCareer" => current_registration_academic_career_secondary,
          "academicLevel" => current_registration_academic_level_secondary,
          "term" => current_registration_term_secondary,
        }
      end
      let(:current_registration_academic_career) { graduate_academic_career }
      let(:current_registration_academic_level) { { "level" => { "code" => "GR", "description" => "Graduate" } } }
      let(:current_registration_term) { {"id" => "2142", "name" => "2014 Spring"} }
      let(:current_registration_academic_career_secondary) { law_academic_career }
      let(:current_registration_academic_level_secondary) { { "level" => { "code" => "P2", "description" => "Professional Year 2" } } }
      let(:current_registration_term_secondary) { {"id" => "2168", "name" => "2016 Fall"} }

      # Hub Academic Status - Student / Academic Careers
      let(:academic_career) { graduate_academic_career }
      let(:student_career_secondary) { {"academicCareer"=> law_academic_career} }
      let(:graduate_academic_career) { { "code"=>"GRAD", "description"=>"Graduate" } }
      let(:law_academic_career) { {"code" => "LAW", "description" => "Law"} }

      # Graduate Statuses - Student Plans
      let(:student_plans) { [law_jd_mpp_cdp_plan] }
      let(:student_plans_secondary) { [graduate_master_public_policy_plan] }

      let(:has_law_role) { true }

      it 'reports success' do
        expect(feed[:collegeAndLevel][:statusCode]).to eq 200
      end

      it 'translates careers' do
        expect(feed[:collegeAndLevel][:careers]).to eq ["Graduate", "Law"]
      end

      it 'translates level' do
        expect(feed[:collegeAndLevel][:level]).to eq 'Graduate and Professional Year 2'
      end

      it 'specifies term name' do
        expect(feed[:collegeAndLevel][:termName]).to eq 'Spring 2014'
      end

      it 'specifies term id' do
        expect(feed[:collegeAndLevel][:termId]).to eq '2142'
      end

      it 'translates majors' do
        expect(feed[:collegeAndLevel][:majors][0]).to eq({
          college: 'Law Professional Programs',
          major: 'Law JD-MPP CDP',
          subPlan: nil
        })
        expect(feed[:collegeAndLevel][:majors][1]).to eq({
          college: 'Graduate Professional Programs',
          major: 'Public Policy MPP-JD CDP',
          subPlan: nil
        })
      end

      it 'translates plans' do
        expect(feed[:collegeAndLevel][:plans].count).to eq 2
        expect(feed[:collegeAndLevel][:plans][0][:career][:code]).to eq 'LAW'
        expect(feed[:collegeAndLevel][:plans][0][:program][:code]).to eq 'LPRFL'
        expect(feed[:collegeAndLevel][:plans][0][:plan][:code]).to eq '84501JDPPG'
        expect(feed[:collegeAndLevel][:plans][0][:expectedGraduationTerm]).to eq nil
        expect(feed[:collegeAndLevel][:plans][0][:role]).to eq 'law'
        expect(feed[:collegeAndLevel][:plans][0][:enrollmentRole]).to eq 'law'
        expect(feed[:collegeAndLevel][:plans][0][:primary]).to eq true
        expect(feed[:collegeAndLevel][:plans][0][:type][:code]).to eq 'MAJ'
        expect(feed[:collegeAndLevel][:plans][0][:type][:category]).to eq 'Major'
        expect(feed[:collegeAndLevel][:plans][0][:college]).to eq 'Law Professional Programs'

        expect(feed[:collegeAndLevel][:plans][1][:career][:code]).to eq 'GRAD'
        expect(feed[:collegeAndLevel][:plans][1][:program][:code]).to eq 'GPRFL'
        expect(feed[:collegeAndLevel][:plans][1][:plan][:code]).to eq '82790PPJDG'
        expect(feed[:collegeAndLevel][:plans][1][:expectedGraduationTerm]).to eq nil
        expect(feed[:collegeAndLevel][:plans][1][:role]).to eq 'default'
        expect(feed[:collegeAndLevel][:plans][1][:enrollmentRole]).to eq 'default'
        expect(feed[:collegeAndLevel][:plans][1][:primary]).to eq true
        expect(feed[:collegeAndLevel][:plans][1][:type][:code]).to eq 'MAJ'
        expect(feed[:collegeAndLevel][:plans][1][:type][:category]).to eq 'Major'
        expect(feed[:collegeAndLevel][:plans][1][:college]).to eq 'Graduate Professional Programs'
      end

      it 'translates roles' do
        expect(feed[:collegeAndLevel][:roles]).to be
      end
    end

    context 'empty status feed' do
      let(:hub_academic_status_feed) { {} }
      it 'reports empty' do
        expect(feed[:collegeAndLevel][:empty]).to eq true
      end
    end

    context 'errored status feed' do
      let(:hub_academic_status_response) do
        {
          :statusCode => 502,
          :body => "An unknown server error occurred",
          :errored => true,
          :studentNotFound => nil
        }
      end
      it 'reports error' do
        expect(feed[:collegeAndLevel][:errored]).to eq true
      end
    end

    context 'status feed lacking some data' do
      let(:current_registration) { {} }
      it 'returns what data it can' do
        expect(feed[:collegeAndLevel][:careers]).to be_present
        expect(feed[:collegeAndLevel][:majors]).to be_present
        expect(feed[:collegeAndLevel][:level]).to be nil
        expect(feed[:collegeAndLevel][:termName]).to be nil
        expect(feed[:collegeAndLevel][:termId]).to be nil
      end
    end
  end

  context '#parse_hub_award_honors' do
    subject { described_class.new(uid).parse_hub_award_honors hub_academic_status_response }

    it 'groups and orders award honors by term' do
      expect(subject.count).to eq(2)
      expect(subject['2128'].count).to eq(2)
      expect(subject['2132'].count).to eq(2)
    end

    it 'contains the expected data for each award honor' do
      expect(subject['2128'][0][:awardDate]).to eq 'Oct 14, 2012'
      expect(subject['2128'][0][:code]).to eq 'HONRDT'
      expect(subject['2128'][0][:description]).to eq 'Honors to Date'
      expect(subject['2128'][1][:awardDate]).to eq 'Oct 14, 2012'
      expect(subject['2128'][1][:code]).to eq 'DEANS'
      expect(subject['2128'][1][:description]).to eq 'Dean\'s List'

      expect(subject['2132'][0][:awardDate]).to eq 'Apr 14, 2013'
      expect(subject['2132'][0][:code]).to eq 'DEANS'
      expect(subject['2132'][0][:description]).to eq 'Dean\'s List'
      expect(subject['2132'][1][:awardDate]).to eq 'Apr 14, 2013'
      expect(subject['2132'][1][:code]).to eq 'HONRDT'
      expect(subject['2132'][1][:description]).to eq 'Honors to Date'
    end
  end

  context '#flatten_plan' do
    let(:flattened_status) { subject.flatten_plan(undergrad_student_plan_major) }

    context 'when input is empty' do
      let(:flattened_status) { subject.flatten_plan({}) }
      it 'returns plan hash with nil values' do
        expect(flattened_status[:career][:code]).to eq nil
        expect(flattened_status[:career][:description]).to eq nil
        expect(flattened_status[:plan][:code]).to eq nil
        expect(flattened_status[:plan][:description]).to eq nil
      end
    end

    it 'handles missing hash nodes gracefully' do
      undergrad_student_plan_major['academicPlan'].delete('academicProgram')
      expect(flattened_status[:career][:code]).to be_nil
      expect(flattened_status[:career][:description]).to be_nil
      expect(flattened_status[:program][:code]).to eq nil
      expect(flattened_status[:program][:description]).to eq nil
      expect(flattened_status[:plan][:code]).to eq '25345U'
      expect(flattened_status[:plan][:description]).to eq 'English BA'
    end

    it 'flattens academic status plan into cpp hash' do
      expect(flattened_status[:career][:code]).to eq 'UGRD'
      expect(flattened_status[:career][:description]).to eq 'Undergraduate'
      expect(flattened_status[:program][:code]).to eq 'UCLS'
      expect(flattened_status[:program][:description]).to eq 'Undergrad Letters & Science'
      expect(flattened_status[:plan][:code]).to eq '25345U'
      expect(flattened_status[:plan][:description]).to eq 'English BA'
    end

    it 'includes the expected graduation term' do
      expect(flattened_status[:expectedGraduationTerm][:code]).to eq '2202'
      expect(flattened_status[:expectedGraduationTerm][:name]).to eq 'Spring 2020'
    end

    it 'includes the students plan role' do
      expect(flattened_status[:role]).to eq 'default'
    end

    it 'includes the students plan enrollment role' do
      expect(flattened_status[:enrollmentRole]).to eq 'default'
    end

    it 'includes the primary plan boolean' do
      expect(flattened_status[:primary]).to eq true
    end

    it 'includes the plan type with category' do
      expect(flattened_status[:type][:code]).to eq 'MAJ'
      expect(flattened_status[:type][:description]).to eq 'Major - Regular Acad/Prfnl'
      expect(flattened_status[:type][:category]).to eq 'Major'
    end

    it 'includes the college name' do
      expect(flattened_status[:college]).to eq 'Undergrad Letters & Science'
    end
  end

  context '#filter_inactive_status_plans' do
    let(:undergrad_student_plan_specialization) do
      hub_edo_academic_status_student_plan({
        career_code: 'UGRD',
        career_description: 'Undergraduate',
        program_code: 'UCLS',
        program_description: 'Undergrad Letters & Science',
        plan_code: '25971U',
        plan_description: 'MCB-Cell & Dev Biology BA',
        role: 'default',
        enrollmentRole: 'default',
        is_primary: false,
        status_in_plan_status_code: 'X',
        status_in_plan_status_description: 'Invalid Status'
      })
    end
    let(:filtered_academic_statuses) { subject.filter_inactive_status_plans(hub_academic_statuses) }
    it 'removes inactive plans from each status' do
      expect(filtered_academic_statuses[0]['studentPlans'].count).to eq 3
      expect(filtered_academic_statuses[0]['studentPlans'][0]['statusInPlan']['status']['code']).to eq 'AC'
      expect(filtered_academic_statuses[0]['studentPlans'][1]['statusInPlan']['status']['code']).to eq 'AC'
      expect(filtered_academic_statuses[0]['studentPlans'][2]['statusInPlan']['status']['code']).to eq 'AC'
      expect(filtered_academic_statuses[0]['studentPlans'][0]['academicPlan']['plan']['code']).to eq '25345U'
      expect(filtered_academic_statuses[0]['studentPlans'][1]['academicPlan']['plan']['code']).to eq '25090U'
      expect(filtered_academic_statuses[0]['studentPlans'][2]['academicPlan']['plan']['code']).to eq '00E017G'
    end
  end

  describe '#profile_in_past?' do
    subject { MyAcademics::CollegeAndLevel.new(uid).profile_in_past? profile }
    let(:profile) { {termName: term_name} }
    context 'profile is for the current CalCentral  term' do
      let(:term_name) { Berkeley::Terms.fetch.current.to_english }
      it {should eq false}
    end
    context 'profile is for the next CalCentral term' do
      let(:term_name) { Berkeley::Terms.fetch.next.to_english }
      it {should eq false}
    end
    context 'profile is for the previous CalCentral term' do
      let(:term_name) { Berkeley::Terms.fetch.previous.to_english }
      it {should eq true}
    end
    context 'profile is empty' do
      let(:profile) { {empty: true} }
      it {should eq false}
    end
  end

end
