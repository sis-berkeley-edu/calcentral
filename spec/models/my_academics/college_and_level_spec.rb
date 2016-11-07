describe MyAcademics::CollegeAndLevel do
  subject { MyAcademics::CollegeAndLevel.new(uid) }
  let(:uid) { '61889' }
  let(:campus_solutions_id) { '1234567890' }
  let(:legacy_campus_solutions_id) { '11667051' }
  let(:bearfacts_proxy) { Bearfacts::Profile.new(user_id: uid, fake: true) }
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
        "holds" => hub_holds
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
    undergrad_student_plan_minor
  ] }
  let(:undergrad_student_plan_major) do
    hub_edo_academic_status_student_plan({
      career_code: 'UGRD',
      career_description: 'Undergraduate',
      program_code: 'UCLS',
      program_description: 'Undergrad Letters & Science',
      plan_code: '25345U',
      plan_description: 'English BA',
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
      type_code: 'SP',
      type_description: 'Major - UG Specialization',
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
      type_code: 'MIN',
      type_description: 'Major - UG Specialization',
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
      admin_owners: [
        {org_code: 'BUS', org_description: 'Haas School of Business', percentage: 50},
        {org_code: 'PUBHEALTH', org_description: 'School of Public Health', percentage: 50},
      ]
    })
  end

  before do
    allow_any_instance_of(CalnetCrosswalk::ByUid).to receive(:lookup_campus_solutions_id).and_return campus_solutions_id
    allow_any_instance_of(HubEdos::AcademicStatus).to receive(:get).and_return hub_academic_status_response
  end

  context 'when defining student plan roles' do
    it 'includes plans and career matchers' do
      expect(subject.class::STUDENT_PLAN_ROLES[:plan].count).to_not eq 0
      expect(subject.class::STUDENT_PLAN_ROLES[:career].count).to_not eq 0
    end

    it 'defines type code and match string for each matcher' do
      subject.class::STUDENT_PLAN_ROLES.values_at(:plan, :career).flatten.each do |matcher|
        expect(matcher).to have_key(:student_plan_role_code)
        expect(matcher).to have_key(:match)
      end
    end

    it 'includes types array' do
      subject.class::STUDENT_PLAN_ROLES.values_at(:plan, :career).flatten.each do |matcher|
        expect(matcher).to have_key(:types)
        expect(matcher[:types]).to be_an Array
        matcher[:types].each do |type|
          expect(type).to be_a Symbol
        end
      end
    end
  end

  context 'when providing student plan role codes' do
    it 'returns all possible student plan role codes' do
      role_codes = subject.class.student_plan_role_codes
      expect(role_codes.count).to eq 10
      expect(role_codes).to include('fpf')
      expect(role_codes).to include('law')
      expect(role_codes).to include('concurrent')
      expect(role_codes).to include('haasFullTimeMba')
      expect(role_codes).to include('haasEveningWeekendMba')
      expect(role_codes).to include('haasExecMba')
      expect(role_codes).to include('haasMastersFinEng')
      expect(role_codes).to include('haasMbaPublicHealth')
      expect(role_codes).to include('haasMbaJurisDoctor')
      expect(role_codes).to include('ugrdUrbanStudies')
    end
  end

  context 'data sourcing' do
    it 'always queries hub data' do
      expect(feed[:collegeAndLevel][:statusCode]).to eq 200
    end
    context 'when hub response is present' do
      it 'sources from EDO Hub' do
        expect(feed[:collegeAndLevel][:level]).to eq 'Junior'
      end
      it 'does not query for bearfacts data' do
        expect(Bearfacts::Profile).to receive(:new).never
        expect(feed[:collegeAndLevel][:statusCode]).to eq 200
      end
    end

    context 'when hub response is empty' do
      let(:hub_academic_status_feed) { {} }
      let(:campus_solutions_id) { legacy_campus_solutions_id }
      context 'when current term is summer' do
        before { allow(subject).to receive(:current_term).and_return(double(is_summer: true)) }
        it 'does not query for bearfacts data' do
          expect(Bearfacts::Profile).to receive(:new).never
          expect(feed[:collegeAndLevel][:statusCode]).to eq 200
        end

        it 'sources from empty EDO Hub response' do
          expect(feed[:collegeAndLevel][:statusCode]).to eq 200
          expect(feed[:collegeAndLevel][:empty]).to eq true
          expect(feed[:collegeAndLevel][:isCurrent]).to eq true
          expect(feed[:collegeAndLevel][:termName]).to eq 'Fall 2013'
        end
      end
      context 'when current term is not summer' do
        before { allow(subject).to receive(:current_term).and_return(fake_spring_term) }
        context 'when bearfacts data is present' do
          before { allow(Bearfacts::Profile).to receive(:new).and_return bearfacts_proxy }
          let(:campus_solutions_id) { legacy_campus_solutions_id }
          it 'sources from bearfacts' do
            expect(feed[:collegeAndLevel][:empty]).to_not be_truthy
            expect(feed[:collegeAndLevel][:level]).to eq 'Senior'
            expect(feed[:collegeAndLevel][:futureTelebearsLevel]).to_not be_nil
          end
        end
        context 'when bearfacts data is not present' do
          it 'sources from empty EDO Hub response' do
            expect(feed[:collegeAndLevel][:empty]).to eq true
            expect(feed[:collegeAndLevel][:isCurrent]).to eq true
            expect(feed[:collegeAndLevel][:termName]).to eq 'Fall 2013'
          end
        end
      end
    end
  end

  context 'when sourced from Hub academic status' do
    context 'failed response' do
      let(:failure_response) { {:errored=>true, :statusCode=>503, :body=>"An unknown server error occurred"} }
      before do
        allow_any_instance_of(HubEdos::AcademicStatus).to receive(:get).and_return(failure_response)
      end
      it 'reports failure' do
        expect(feed[:collegeAndLevel][:statusCode]).to eq 503
        expect(feed[:collegeAndLevel][:empty]).to eq true
        expect(feed[:collegeAndLevel][:errored]).to eq true
        expect(feed[:collegeAndLevel][:body]).to eq "An unknown server error occurred"
      end
    end
    context 'undergrad with single academic status' do
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

      it 'translates minors' do
        expect(feed[:collegeAndLevel][:minors].first).to eq({
          college: 'Undergrad Letters & Science',
          minor: 'Art BA'
        })
      end

      it 'translates majors' do
        expect(feed[:collegeAndLevel][:majors][0]).to eq({
          college: 'Undergrad Letters & Science',
          major: 'English BA'
        })
        expect(feed[:collegeAndLevel][:majors][1]).to eq({
          college: 'Undergrad Letters & Science',
          major: 'MCB-Cell & Dev Biology BA'
        })
      end

      it 'translates plans' do
        expect(feed[:collegeAndLevel][:plans].count).to eq 3

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
      end

      it 'translates roles' do
        expect(feed[:collegeAndLevel][:roles].keys.count).to eq 10
        expect(feed[:collegeAndLevel][:roles]['fpf']).to eq false
        expect(feed[:collegeAndLevel][:roles]['law']).to eq false
        expect(feed[:collegeAndLevel][:roles]['concurrent']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasFullTimeMba']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasEveningWeekendMba']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasExecMba']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasMastersFinEng']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasMbaPublicHealth']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasMbaJurisDoctor']).to eq false
        expect(feed[:collegeAndLevel][:roles]['ugrdUrbanStudies']).to eq false
      end

      it 'translates holds' do
        expect(feed[:collegeAndLevel][:holds][:hasHolds]).to eq true
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

      it 'translates majors' do
        expect(feed[:collegeAndLevel][:majors][0]).to eq({
          college: 'Law Professional Programs',
          major: 'Law JD-MPP CDP'
        })
        expect(feed[:collegeAndLevel][:majors][1]).to eq({
          college: 'Graduate Professional Programs',
          major: 'Public Policy MPP-JD CDP'
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
        expect(feed[:collegeAndLevel][:roles].keys.count).to eq 10
        expect(feed[:collegeAndLevel][:roles]['fpf']).to eq false
        expect(feed[:collegeAndLevel][:roles]['law']).to eq true
        expect(feed[:collegeAndLevel][:roles]['concurrent']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasFullTimeMba']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasEveningWeekendMba']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasExecMba']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasMastersFinEng']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasMbaPublicHealth']).to eq false
        expect(feed[:collegeAndLevel][:roles]['haasMbaJurisDoctor']).to eq false
        expect(feed[:collegeAndLevel][:roles]['ugrdUrbanStudies']).to eq false
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
      end
    end
  end

  context 'when sourced from Bearfacts' do
    let(:campus_solutions_id) { legacy_campus_solutions_id }
    before do
      allow_any_instance_of(HubEdos::AcademicStatus).to receive(:get).and_return({})
      allow(subject).to receive(:current_term).and_return(fake_spring_term)
    end

    context 'known test users' do
      let(:majors) { feed[:collegeAndLevel][:majors] }
      before do
        expect(Bearfacts::Profile).to receive(:new).and_return bearfacts_proxy
        expect(feed).not_to be_empty
      end

      it 'should get properly formatted data from fake Bearfacts' do
        expect(majors).to have(1).items
        expect(majors.first).to include(
          college: 'College of Letters & Science',
          major: 'Statistics'
        )
        expect(feed[:collegeAndLevel]).to include(
          careers: [
            'Undergraduate'
          ],
          termName: 'Fall 2015'
        )
      end

      context 'enrollment in multiple colleges' do
        let(:uid) { '300940' }
        it 'should return multiple colleges and majors' do
          expect(majors).to have(2).items
          expect(majors[0]).to include(
            college: 'College of Natural Resources',
            major: 'Conservation And Resource Studies'
          )
          expect(majors[1]).to include(
            college: 'College of Environmental Design',
            major: 'Landscape Architecture'
          )
        end
      end

      context 'a concurrent enrollment triple major' do
        let(:uid) { '212379' }
        it 'should return even more colleges and majors' do
          expect(majors).to have(3).items
          expect(majors[0]).to include(
            college: 'College of Chemistry',
            major: 'Chemistry'
          )
          expect(majors[1]).to include(
            college: 'College of Letters & Science',
            major: 'Applied Mathematics'
          )
          expect(majors[2]).to include(
            college: '',
            major: 'Physics'
          )
        end
      end

      context 'a double law major' do
        let(:uid) { '212381' }
        it 'should return the law in all its aspects' do
          expect(majors).to have(2).items
          expect(majors[0]).to include(
            college: 'School of Law',
            major: 'Jurisprudence And Social Policy'
          )
          expect(majors[1]).to include(
            college: '',
            major: 'Law'
          )
        end
      end
    end

    context 'when bearfacts proxy is failing' do
      let(:uid) {'212381'}
      let(:feed) {{}}
      before(:each) do
        stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Errno::EHOSTUNREACH)
        Bearfacts::Profile.new({user_id: uid, fake: false})
      end
      it 'sources from failed EDO Hub response' do
        MyAcademics::CollegeAndLevel.new(uid).merge(feed)
        expect(feed[:collegeAndLevel][:empty]).to be_truthy
        expect(feed[:collegeAndLevel][:termName]).to eq 'Fall 2013'
      end
    end

    context 'when Bearfacts feed is incomplete' do
      let(:uid) {rand(999999)}
      let(:feed) {{}}
      before do
        allow(Bearfacts::Profile).to receive(:new).with(user_id: uid).and_return(double(get: {
          feed: FeedWrapper.new(MultiXml.parse(xml_body))
        }))
        MyAcademics::CollegeAndLevel.new(uid).merge(feed)
      end

      context 'when Bearfacts student profile lacks key data' do
        let(:xml_body) {
          '<studentProfile xmlns="urn:berkeley.edu/babl" termName="Spring" termYear="2014" asOfDate="May 27, 2014 12:00 AM"><studentType>STUDENT</studentType><noProfileDataFlag>false</noProfileDataFlag><studentGeneralProfile><studentName><firstName>OWPRQTOPEW</firstName><lastName>SEBIRTFEIWB</lastName></studentName></studentGeneralProfile></studentProfile>'
        }
        it 'reports an empty feed for the CalCentral current term' do
          expect(feed[:collegeAndLevel]).to include(
            empty: true,
            termName: Berkeley::Terms.fetch.current.to_english
          )
          expect(feed[:collegeAndLevel]).not_to include :errored
        end
      end

      context 'when Bearfacts student profile is completely empty' do
        let(:xml_body) { nil }
        it 'reports an empty feed for the CalCentral current term' do
          expect(feed[:collegeAndLevel]).to include(
            empty: true,
            termName: Berkeley::Terms.fetch.current.to_english
          )
          expect(feed[:collegeAndLevel]).not_to include :errored
        end
      end
    end
  end

  context 'when flattening a student academic plan' do
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

  context 'when filtering inactive academic status data' do
    let(:undergrad_student_plan_specialization) do
      hub_edo_academic_status_student_plan({
        career_code: 'UGRD',
        career_description: 'Undergraduate',
        program_code: 'UCLS',
        program_description: 'Undergrad Letters & Science',
        plan_code: '25971U',
        plan_description: 'MCB-Cell & Dev Biology BA',
        is_primary: false,
        status_in_plan_status_code: 'X',
        status_in_plan_status_description: 'Invalid Status'
      })
    end

    context 'when filtering out inactive plans from statuses' do
      let(:filtered_academic_statuses) { subject.filter_inactive_status_plans(hub_academic_statuses) }
      it 'removes inactive plans from each status' do
        expect(filtered_academic_statuses[0]['studentPlans'].count).to eq 2
        expect(filtered_academic_statuses[0]['studentPlans'][0]['statusInPlan']['status']['code']).to eq 'AC'
        expect(filtered_academic_statuses[0]['studentPlans'][1]['statusInPlan']['status']['code']).to eq 'AC'
        expect(filtered_academic_statuses[0]['studentPlans'][0]['academicPlan']['plan']['code']).to eq '25345U'
        expect(filtered_academic_statuses[0]['studentPlans'][1]['academicPlan']['plan']['code']).to eq '25090U'
      end
    end
  end

  context 'when determining the student plan role code' do
    let(:plan) { { career: { code: 'GRAD' }, plan: { code: '70141MBAG' } } }

    context 'when role type not specified' do
      let(:plan_role_code) { subject.get_student_plan_role_code(plan) }

      it 'identifies a default plan in undergrad career' do
        plan[:career][:code] = 'UGRD'
        plan[:plan][:code] = '25699U'
        expect(plan_role_code).to eq 'default'
      end

      it 'identifies a default plan in graduate career' do
        plan[:career][:code] = 'GRAD'
        plan[:plan][:code] = '16290PHDG'
        expect(plan_role_code).to eq 'default'
      end

      it 'identifies a berkeley law career plan' do
        plan[:career][:code] = 'LAW'
        plan[:plan][:code] = '842C1JSDG'
        expect(plan_role_code).to eq 'law'
      end

      it 'identifies a concurrent enrollment plan' do
        plan[:career][:code] = 'UCBX'
        plan[:plan][:code] = '30XCECCENX'
        expect(plan_role_code).to eq 'concurrent'
      end

      it 'identifies a fall program for freshmen plan' do
        plan[:career][:code] = 'UGRD'
        plan[:plan][:code] = '25000FPFU'
        expect(plan_role_code).to eq 'fpf'
      end

      it 'identifies a Haas Business School Fulltime MBA plan' do
        plan[:career][:code] = 'GRAD'
        plan[:plan][:code] = '70141MBAG'
        expect(plan_role_code).to eq 'haasFullTimeMba'
      end

      it 'identifies a Haas Business School Evening and Weekend MBA plan' do
        plan[:career][:code] = 'GRAD'
        plan[:plan][:code] = '701E1MBAG'
        expect(plan_role_code).to eq 'haasEveningWeekendMba'
      end

      it 'identifies a Haas Business School Executive MBA plan' do
        plan[:career][:code] = 'GRAD'
        plan[:plan][:code] = '70364MBAG'
        expect(plan_role_code).to eq 'haasExecMba'
      end

      it 'identifies a Haas Business School Masters of Financial Engineering plan' do
        plan[:career][:code] = 'GRAD'
        plan[:plan][:code] = '701F1MFEG'
        expect(plan_role_code).to eq 'haasMastersFinEng'
      end

      it 'identifies a Haas Business School Business Admin MBA-MPH plan' do
        plan[:career][:code] = 'GRAD'
        plan[:plan][:code] = '70141BAPHG'
        expect(plan_role_code).to eq 'haasMbaPublicHealth'
      end

      it 'identifies a Haas Business School Business Admin MBA-JD plan' do
        plan[:career][:code] = 'GRAD'
        plan[:plan][:code] = '70141BAJDG'
        expect(plan_role_code).to eq 'haasMbaJurisDoctor'
      end
    end

    context 'when enrollment role type specified' do
      let(:role_type) { :enrollment }
      let(:plan_role_code) { subject.get_student_plan_role_code(plan, role_type) }

      it 'identifies Haas Business School plans as default' do
        haas_plan_codes = ['70141MBAG', '701E1MBAG', '70364MBAG', '701F1MFEG', '70141BAPHG', '70141BAJDG']
        haas_plan_codes.each do |haas_plan_code|
          plan_hash = { career: { code: 'GRAD' }, plan: { code: haas_plan_code } }
          expect(plan_role_code).to eq 'default'
        end
      end
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
