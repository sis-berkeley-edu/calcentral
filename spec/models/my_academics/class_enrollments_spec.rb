describe MyAcademics::ClassEnrollments do
  let(:student_uid) { '123456' }
  let(:student_emplid) { '12000001' }
  let(:is_feature_enabled_flag) { true }
  let(:user_is_student) { false }
  let(:cs_enrollment_term_detail) do
    {
      studentId: student_emplid,
      term: '216X',
      termDescr: 'Afterlithe 2016',
      isClassScheduleAvailable: true,
      isEndOfDropAddTimePeriod: false,
      links: {},
      advisors: [],
      enrollmentPeriod: [
        {
          :id=>"R8P1",
          :name=>"Phase 1 Begins",
          :date=>{:epoch=>1508276400, :datetime=>"2017-10-17T14:40:00-07:00", :datestring=>"10/17"}
        },
        {
          :id=>"R8P2",
          :name=>"Phase 2 Begins",
          :date=>{:epoch=>1510785600, :datetime=>"2017-11-15T14:40:00-08:00", :datestring=>"11/15"}
        },
        {
          :id=>"ADJ",
          :name=>"Adjustment Begins",
          :date=>{:epoch=>1515430800, :datetime=>"2018-01-08T09:00:00-08:00", :datestring=>"1/08"}
        }
      ],
      scheduleOfClassesPeriod: {
        :date => {
          :epoch=>1506841200,
          :datetime=>"2017-10-01T00:00:00-07:00",
          :datestring=>"10/01"
        }
      },
      enrolledClasses: [],
      waitlistedClasses: [],
      enrolledClassesTotalUnits: 8.0,
      waitlistedClassesTotalUnits: 2.0,
    }
  end
  let(:has_holds) { false }
  let(:term_id) { '2168' }
  let(:term_cpp) { :ugrd_nutritional_science_plan_2168_term_cpp }
  let(:student_plans) { [undergrad_nutritional_science_plan] }
  let(:undergrad_career) do
    {
      'academicCareer' => { 'code' => 'UGRD', 'description' => 'Undergraduate' },
      :role => 'ugrd'
    }
  end
  let(:undergrad_nutritional_science_plan) do
    {
      career: undergrad_career,
      program: { code: 'UCNR', description: 'Undergrad Natural Resources' },
      plan: { code: '04606U', description: 'Nutritional Science BS' },
      type: { code: 'MAJ', description: 'Major - Regular Acad/Prfnl', category: 'Major' },
      college: 'Undergrad Natural Resources',
      role: [],
      statusInPlan: {
        status: { code: 'AC' }
      },
      primary: true,
    }
  end
  let(:ugrd_nutritional_science_plan_2168_term_cpp) do
    [
      {'term_id'=>'2168', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
    ]
  end
  let(:ugrd_computer_science_plan_2168_term_cpp) do
    [
      {'term_id'=>'2168', 'acad_career'=>'UGRD', 'acad_program'=>'UCLS', 'acad_plan'=>'25201U'},
    ]
  end
  let(:ugrd_cognitive_science_plan_2168_term_cpp) do
    [
      {'term_id'=>'2168', 'acad_career'=>'UGRD', 'acad_program'=>'UCLS', 'acad_plan'=>'25179U'},
    ]
  end
  let(:ugrd_fall_program_for_freshmen_plan_2168_term_cpp) do
    [
      {'term_id'=>'2168', 'acad_career'=>'UGRD', 'acad_program'=>'UCLS', 'acad_plan'=>'25000FPFU'},
    ]
  end
  let(:grad_electrical_engineering_plan_2168_term_cpp) do
    [
      {'term_id'=>'2168', 'acad_career'=>'GRAD', 'acad_program'=>'GACAD', 'acad_plan'=>'16290PHDG'},
    ]
  end
  let(:grad_electrical_engineering_plan_2172_term_cpp) do
    [
      {'term_id'=>'2172', 'acad_career'=>'GRAD', 'acad_program'=>'GACAD', 'acad_plan'=>'16290PHDG'},
    ]
  end
  let(:law_jsp_2168_term_cpp) do
    [
      {'term_id'=>'2168', 'acad_career'=>'LAW', 'acad_program'=>'LACAD', 'acad_plan'=>'84485PHDG'},
    ]
  end
  let(:law_jsp_2172_term_cpp) do
    [
      {'term_id'=>'2172', 'acad_career'=>'LAW', 'acad_program'=>'LACAD', 'acad_plan'=>'84485PHDG'},
    ]
  end
  let(:cs_enrollment_career_terms) {
    [
      cs_career_term_ugrd_summer_2016,
      cs_career_term_grad_fall_2016,
      cs_career_term_law_fall_2016
    ]
  }
  let(:cs_career_term_ugrd_summer_2016) { { termId: '2165', termDescr: '2016 Summer', acadCareer: 'UGRD' } }
  let(:cs_career_term_ugrd_fall_2016) { { termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' } }
  let(:cs_career_term_ugrd_spring_2017) { { termId: '2172', termDescr: '2017 Spring', acadCareer: 'UGRD' } }

  let(:cs_career_term_grad_fall_2016) { { termId: '2168', termDescr: '2016 Fall', acadCareer: 'GRAD' } }
  let(:cs_career_term_law_fall_2016) { { termId: '2168', termDescr: '2016 Fall', acadCareer: 'LAW' } }

  subject { MyAcademics::ClassEnrollments.new(student_uid) }
  before do
    allow(subject).to receive(:is_feature_enabled).and_return(is_feature_enabled_flag)
    allow(subject).to receive(:user_is_student?).and_return(user_is_student)
    allow(MyAcademics::MyAcademicStatus).to receive(:has_holds?).and_return(has_holds)
    allow(CampusSolutions::MyEnrollmentTerms).to receive(:get_terms).and_return(cs_enrollment_career_terms)
    allow(CampusSolutions::MyEnrollmentTerm).to receive(:get_term) do |uid, term_id|
      cs_enrollment_term_detail.merge({:term => term_id})
    end
    allow_any_instance_of(Berkeley::Term).to receive(:campus_solutions_id).and_return(term_id)
    allow_any_instance_of(User::Academics::TermPlans::TermPlansCached).to receive(:get_feed).and_return(term_cpp)
  end

  context 'when providing the class enrollment instructions feed for a student' do
    context 'when the user is not a student' do
      it 'returns an empty hash' do
        expect(subject.get_feed).to eq({})
      end
    end

    context 'when the class enrollment card feature is disabled' do
      let(:is_feature_enabled_flag) { false }
      it 'includes returns an empty hash' do
        expect(subject.get_feed).to eq({})
      end
    end

    context 'when the user is a student' do
      let(:term_cpp) { ugrd_computer_science_plan_2168_term_cpp }
      let(:cs_enrollment_career_terms) { [{ termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' }] }
      let(:user_is_student) { true }
      let(:feed) { subject.get_feed }
      it 'include enrollment instruction type decks' do
        types = feed[:enrollmentTermInstructionTypeDecks]
        expect(types.count).to eq 1
        expect(types[0][:cards][0][:role]).to eq 'default'
        expect(types[0][:cards][0][:careerCode]).to eq 'UGRD'
        expect(types[0][:cards][0][:academicPlans].count).to eq 1
        expect(types[0][:cards][0][:term][:termId]).to eq '2168'
        expect(types[0][:cards][0][:term][:termDescr]).to eq '2016 Fall'
      end
      it 'includes enrollment instructions for each active term' do
        instructions = feed[:enrollmentTermInstructions]
        expect(instructions.keys.count).to eq 1
        expect(instructions[:'2168'][:studentId]).to eq student_emplid
        expect(instructions[:'2168'][:term]).to eq '2168'
      end
      it 'includes academic planner data for each term' do
        plans = feed[:enrollmentTermAcademicPlanner]
        expect(plans.keys.count).to eq 1
        expect(plans[:'2168']).to have_key(:studentId)
        expect(plans[:'2168'][:updateAcademicPlanner][:name]).to eq 'Update'
        expect(plans[:'2168'][:academicplanner].count).to eq 1
      end
      it 'includes users hold status' do
        expect(feed[:hasHolds]).to eq false
      end
      it 'includes campus solutions deeplinks' do
        expect(feed[:links].count).to be 5
        expect(feed[:links][:ucAddClassEnrollment]).to be
        expect(feed[:links][:ucEditClassEnrollment]).to be
        expect(feed[:links][:ucViewClassEnrollment]).to be
        expect(feed[:links][:requestLateClassChanges]).to be
        expect(feed[:links][:crossCampusEnroll]).to be
      end
    end
  end

  context 'when grouping student plans by role' do
    let(:student_plan_roles) { subject.grouped_student_plan_roles }
    let(:term_cpp) do
      ugrd_computer_science_plan_2168_term_cpp + grad_electrical_engineering_plan_2168_term_cpp + law_jsp_2168_term_cpp
    end
    it 'groups plans by role and career code' do
      expect(student_plan_roles).to have_keys([ ['default','UGRD', '2168'], ['default','GRAD', '2168'], ['law','LAW','2168'] ])
    end
    it 'includes role code with each student plan role' do
      expect(student_plan_roles[['default','UGRD', '2168']][:role]).to eq 'default'
      expect(student_plan_roles[['default','GRAD', '2168']][:role]).to eq 'default'
      expect(student_plan_roles[['law','LAW', '2168']][:role]).to eq 'law'
    end
    it 'includes career code with each student plan role' do
      expect(student_plan_roles[['default','UGRD', '2168']][:career_code]).to eq 'UGRD'
      expect(student_plan_roles[['default','GRAD', '2168']][:career_code]).to eq 'GRAD'
      expect(student_plan_roles[['law','LAW', '2168']][:career_code]).to eq 'LAW'
    end
    it 'includes plans with each student plan role' do
      expect(student_plan_roles[['default','UGRD', '2168']][:academic_plans].count).to eq 1
      expect(student_plan_roles[['default','GRAD', '2168']][:academic_plans].count).to eq 1
      expect(student_plan_roles[['law','LAW', '2168']][:academic_plans].count).to eq 1
      expect(student_plan_roles[['default','UGRD', '2168']][:academic_plans][0][:plan][:code]).to eq '25201U'
      expect(student_plan_roles[['default','GRAD', '2168']][:academic_plans][0][:plan][:code]).to eq '16290PHDG'
      expect(student_plan_roles[['law','LAW', '2168']][:academic_plans][0][:plan][:code]).to eq '84485PHDG'
    end
  end

  context 'when providing career term role decks' do
    let(:term_cpp) do
      ugrd_computer_science_plan_2168_term_cpp + grad_electrical_engineering_plan_2172_term_cpp + law_jsp_2172_term_cpp
    end
    let(:decks) { subject.get_career_term_role_decks }
    context 'when more than one role in any term' do
      let(:cs_enrollment_career_terms) do
        [
          { termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' },
          { termId: '2172', termDescr: '2017 Spring', acadCareer: 'GRAD' },
          { termId: '2172', termDescr: '2017 Spring', acadCareer: 'LAW' },
        ]
      end
      it 'groups roles into decks by design' do
        expect(decks).to be_an_instance_of Array
        expect(decks.length).to eq 2
        expect(decks[0][:cards].length).to eq 2
        expect(decks[1][:cards].length).to eq 1
        expect(decks[0][:cards][0][:role]).to eq 'default'
        expect(decks[0][:cards][0][:term][:termId]).to eq '2168'
        expect(decks[0][:cards][1][:role]).to eq 'default'
        expect(decks[0][:cards][1][:term][:termId]).to eq '2172'
        expect(decks[1][:cards][0][:role]).to eq 'law'
        expect(decks[1][:cards][0][:term][:termId]).to eq '2172'
      end
    end
    context 'when no more than one role exists in any term' do
      let(:law_jsp_2175_term_cpp) do
        [
          {'term_id'=>'2175', 'acad_career'=>'LAW', 'acad_program'=>'LACAD', 'acad_plan'=>'84485PHDG'},
        ]
      end
      let(:term_cpp) do
        ugrd_computer_science_plan_2168_term_cpp + grad_electrical_engineering_plan_2172_term_cpp + law_jsp_2175_term_cpp
      end
      let(:cs_enrollment_career_terms) do
        [
          { termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' },
          { termId: '2172', termDescr: '2017 Spring', acadCareer: 'GRAD' },
          { termId: '2175', termDescr: '2017 Summer', acadCareer: 'LAW' },
        ]
      end
      it 'groups roles into single deck' do
        expect(decks).to be_an_instance_of Array
        expect(decks.length).to eq 1
        expect(decks[0][:cards].length).to eq 3
        expect(decks[0][:cards][0][:role]).to eq 'default'
        expect(decks[0][:cards][0][:term][:termId]).to eq '2168'
        expect(decks[0][:cards][1][:role]).to eq 'default'
        expect(decks[0][:cards][1][:term][:termId]).to eq '2172'
        expect(decks[0][:cards][2][:role]).to eq 'law'
        expect(decks[0][:cards][2][:term][:termId]).to eq '2175'
      end
    end
    context 'when no plans present for student' do
      let(:term_cpp) { [] }
      it 'returns empty array' do
        expect(decks).to be_an_instance_of Array
        expect(decks.length).to eq 0
      end
    end
  end

  context 'when determining if a career term role set has multiple career-term roles within any term' do
    let(:ugrd_2168_career_term_role) {
      {
        :role=>"default",
        :career_code=>"UGRD",
        :academic_plans=>[],
        :term=>{
          :termId=>"2168",
          :termDescr=>"2016 Fall"
        }
      }
    }
    let(:grad_2172_career_term_role) {
      {
        :role=>"default",
        :career_code=>"GRAD",
        :academic_plans=>[],
        :term=>{
          :termId=>"2172",
          :termDescr=>"2017 Spring"
        }
      }
    }
    let(:law_2172_career_term_role) {
      {
        :role=>"law",
        :career_code=>"LAW",
        :academic_plans=>[],
        :term=>{
          :termId=>"2172",
          :termDescr=>"2017 Spring"
        }
      }
    }
    context 'when career term role set has multiple career-term roles within a term' do
      let(:career_term_roles_set) { [ugrd_2168_career_term_role, grad_2172_career_term_role, law_2172_career_term_role] }
      it 'returns true' do
        expect(subject.has_multiple_career_term_roles_in_any_term?(career_term_roles_set)).to eq true
      end
    end
    context 'when career term role set does not have multiple career-term roles within a term' do
      let(:career_term_roles_set) { [ugrd_2168_career_term_role, grad_2172_career_term_role] }
      it 'returns false' do
        expect(subject.has_multiple_career_term_roles_in_any_term?(career_term_roles_set)).to eq false
      end
    end
  end

  context 'when providing career term roles' do
    let(:career_term_roles) { subject.get_career_term_roles }
    let(:term_id) { '2165' }
    let(:cs_enrollment_career_terms) do
      [
        { termId: '2165', termDescr: '2016 Summer', acadCareer: 'UGRD' },
        { termId: '2168', termDescr: '2016 Fall', acadCareer: 'GRAD' },
        { termId: '2168', termDescr: '2016 Fall', acadCareer: 'LAW' }
      ]
    end
    context 'when multiple student plan roles match a career code for an active career-term' do
      let(:term_cpp) do
        ugrd_computer_science_plan_2168_term_cpp + ugrd_cognitive_science_plan_2168_term_cpp + law_jsp_2168_term_cpp
      end
      let(:cs_enrollment_career_terms) { [{ termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' }] }
      it 'excludes student plan roles with non-matching career code' do
        expect(career_term_roles.count).to eq 1
      end
      it 'includes multiple plans of the same type in the same career-term' do
        expect(career_term_roles[0][:academic_plans].count).to eq 2
        plans = career_term_roles[0][:academic_plans]
        plan_codes = plans.collect {|plan| plan[:plan][:code] }
        expect(plan_codes).to include('25201U', '25179U')
      end
      it 'includes term code and description' do
        expect(career_term_roles[0][:term][:termId]).to eq '2168'
        expect(career_term_roles[0][:term][:termDescr]).to eq '2016 Fall'
      end
    end

    context 'when a student plan role matches a career code for multiple active career-terms' do
      let(:term_cpp) { law_jsp_2168_term_cpp }
      let(:cs_enrollment_career_terms) {
        [
          { termId: '2168', termDescr: '2016 Fall', acadCareer: 'LAW' },
          { termId: '2172', termDescr: '2017 Spring', acadCareer: 'LAW' },
        ]
      }
      it 'includes the plans for each matching career-term' do
        expect(career_term_roles.count).to eq 1
        expect(career_term_roles[0][:academic_plans].count).to eq 1
        expect(career_term_roles[0][:academic_plans][0][:plan][:code]).to eq '84485PHDG'
        expect(career_term_roles[0][:term][:termId]).to eq '2168'
        expect(career_term_roles[0][:term][:termDescr]).to eq '2016 Fall'
      end
    end

    context 'when a student plan role does not match the career code for any active career-term' do
      let(:term_cpp) do
        law_jsp_2172_term_cpp
      end
      let(:cs_enrollment_career_terms) { [{ termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' }] }
      it 'does not include an career term role object for the student plan role' do
        expect(career_term_roles.count).to eq 0
      end
    end

    context 'when a student plan role is fpf and matches multiple career-terms' do
      let(:term_id) { '2168' }
      let(:ugrd_chem_2172_term_cpp) { [{'term_id'=>'2172', 'acad_career'=>'UGRD', 'acad_program'=>'UCCH', 'acad_plan'=>'10294U'}] }
      let(:term_cpp) do
        ugrd_fall_program_for_freshmen_plan_2168_term_cpp + ugrd_chem_2172_term_cpp
      end
      let(:cs_enrollment_career_terms) { [
        { termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' },
        { termId: '2172', termDescr: '2017 Spring', acadCareer: 'UGRD' },
        { termId: '2175', termDescr: '2017 Summer', acadCareer: 'UGRD' },
      ] }
      it 'applies the fpf role to the fall 2016 term role object' do
        expect(career_term_roles.count).to eq 2
        expect(career_term_roles[0][:role]).to eq 'fpf'
        expect(career_term_roles[0][:career_code]).to eq 'UGRD'
        expect(career_term_roles[0][:academic_plans].count).to eq 1
        expect(career_term_roles[0][:academic_plans][0][:plan][:code]).to eq '25000FPFU'
        expect(career_term_roles[0][:term][:termId]).to eq '2168'
      end
      it 'applies a default career term role to the Spring 2017 object' do
        expect(career_term_roles[1][:role]).to eq 'default'
        expect(career_term_roles[1][:career_code]).to eq 'UGRD'
        expect(career_term_roles[1][:academic_plans].count).to eq 1
        expect(career_term_roles[1][:academic_plans][0][:plan][:code]).to eq '10294U'
        expect(career_term_roles[1][:term][:termId]).to eq '2172'
      end
      it 'does not return a summer 2017 object' do
        expect(career_term_roles[2]).to eq nil
      end
    end

    context 'when a student plan roles are fpf and default and both match multiple career-terms' do
      let(:term_id) { '2168' }
      let(:term_cpp) do
        ugrd_fall_program_for_freshmen_plan_2168_term_cpp + ugrd_nutritional_science_plan_2168_term_cpp
      end
      let(:cs_enrollment_career_terms) { [
        { termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' },
        { termId: '2172', termDescr: '2017 Spring', acadCareer: 'UGRD' }
      ] }
      it 'applies the fpf role only to the first term and default only to the second' do
        expect(career_term_roles.count).to eq 2
        expect(career_term_roles[0][:role]).to eq 'fpf'
        expect(career_term_roles[0][:career_code]).to eq 'UGRD'
        expect(career_term_roles[0][:academic_plans].count).to eq 1
        expect(career_term_roles[0][:academic_plans][0][:plan][:code]).to eq '25000FPFU'
        expect(career_term_roles[0][:term][:termId]).to eq '2168'
        expect(career_term_roles[1][:role]).to eq 'default'
        expect(career_term_roles[1][:career_code]).to eq 'UGRD'
        expect(career_term_roles[1][:academic_plans].count).to eq 1
        expect(career_term_roles[1][:academic_plans][0][:plan][:code]).to eq '04606U'
        expect(career_term_roles[1][:term][:termId]).to eq '2168'
      end
    end
  end

  context 'when providing term academic plans by term' do
    let(:academic_plans) { subject.get_enrollment_term_academic_planner }
    context 'when terms present' do
      it 'indexes the object by each term id' do
        expect(academic_plans.keys).to eq ['2165', '2168']
      end
      it 'includes plans for each term' do
        expect(academic_plans.keys.count).to eq 2
        academic_plans.keys.each do |term_key|
          plan = academic_plans[term_key]
          expect(plan[:studentId]).to eq '24437121'
          expect(plan[:updateAcademicPlanner]).to have_key(:name)
          expect(plan[:updateAcademicPlanner]).to have_key(:url)
          expect(plan[:updateAcademicPlanner]).to have_key(:isCsLink)
          expect(plan[:academicplanner][0]).to have_key(:term)
          expect(plan[:academicplanner][0]).to have_key(:termDescr)
          expect(plan[:academicplanner][0]).to have_key(:classes)
          expect(plan[:academicplanner][0]).to have_key(:totalUnits)
        end
      end
    end

    context 'when no active terms' do
      let(:cs_enrollment_career_terms) { [] }
      it 'returns no plans' do
        expect(academic_plans).to eq({})
      end
    end
  end

  context 'when providing instruction data by term' do
    let(:term_instructions) { subject.get_enrollment_term_instructions }
    context 'when providing enrollment instruction data for each term' do
      context 'when terms present' do
        it 'indexes the object by each term id' do
          expect(term_instructions.keys).to eq ['2165', '2168']
        end
        it 'includes details for each term' do
          expect(term_instructions.keys.count).to eq 2
          term_instructions.keys.each do |term_key|
            term_detail = term_instructions[term_key]
            expect(term_detail[:studentId]).to eq '12000001'
            expect(term_detail[:term]).to eq term_key
            expect(term_detail[:termDescr]).to eq 'Afterlithe 2016'
          end
        end
        it 'includes application deadline date for concurrent enrollment students for each term' do
          expect(term_instructions.keys.count).to eq 2
        end
        it 'includes period timezone offsets' do
          expect(term_instructions.keys.count).to eq 2
          expect(term_instructions['2165'][:scheduleOfClassesPeriod][:date][:datetime]).to eq '2017-10-01T00:00:00-07:00'
          expect(term_instructions['2165'][:scheduleOfClassesPeriod][:date][:offset]).to eq '-0700'
          expect(term_instructions['2165'][:enrollmentPeriod][0][:date][:datetime]).to eq '2017-10-17T14:40:00-07:00'
          expect(term_instructions['2165'][:enrollmentPeriod][0][:date][:offset]).to eq '-0700'
          expect(term_instructions['2165'][:enrollmentPeriod][1][:date][:datetime]).to eq '2017-11-15T14:40:00-08:00'
          expect(term_instructions['2165'][:enrollmentPeriod][1][:date][:offset]).to eq '-0800'
          expect(term_instructions['2165'][:enrollmentPeriod][2][:date][:datetime]).to eq '2018-01-08T09:00:00-08:00'
          expect(term_instructions['2165'][:enrollmentPeriod][2][:date][:offset]).to eq '-0800'
        end
        context 'when application deadline date not available for term' do
          before { Settings.class_enrollment.concurrent_apply_deadlines.delete_at(1) }
          it 'defaults to TBD' do
            expect(term_instructions.keys.count).to eq 2
          end
        end
      end
      context 'when no active terms' do
        let(:cs_enrollment_career_terms) { [] }
        it 'returns no term details' do
          expect(term_instructions).to eq({})
        end
      end
    end
  end

  context '#get_active_term_ids' do
    let(:result) { subject.get_active_term_ids }
    let(:active_career_terms) { [] }
    before { allow(subject).to receive(:get_active_career_terms).and_return(active_career_terms) }
    context 'when enrollment terms are not available' do
      let(:active_career_terms) { [] }
      it 'returns empty array' do
        expect(result).to eq []
      end
    end
    context 'when enrollment terms are available' do
      let(:active_career_terms) do
        [
          {
            termId: '2195',
            termDescr: '2019 Summer',
            termName: 'Summer 2019',
            termIsSummer: true,
            acadCareer: 'UGRD',
          },
          {
            termId: '2198',
            termDescr: '2019 Fall',
            termName: 'Fall 2019',
            termIsSummer: false,
            acadCareer: 'UGRD',
          },
        ]
      end
      it 'provides term ids for each active career term' do
        expect(result).to eq ['2195', '2198']
      end
      context 'when duplicate enrollment terms are provided' do
        let(:active_career_terms) do
          [
            {termId: '2195'},
            {termId: '2195'},
            {termId: '2195'},
            {termId: '2198'},
            {termId: '2198'},
          ]
        end
        it 'provides unique term ids for each active career term' do
          expect(result).to eq ['2195', '2198']
        end
      end
    end
  end

  context '#get_active_career_terms' do
    let(:result) { subject.get_active_career_terms }
    before do
      allow(CampusSolutions::MyEnrollmentTerms).to receive(:get_terms).and_return(my_enrollment_terms)
    end
    context 'when enrollment terms are available' do
      let(:my_enrollment_terms) { [{termId: '2195', termDescr: '2019 Summer', acadCareer: 'UGRD'}] }
      it 'returns active terms for each career' do
        expect(result.count).to eq 1
        expect(result[0][:termId]).to eq '2195'
        expect(result[0][:termDescr]).to eq '2019 Summer'
        expect(result[0][:termName]).to eq 'Summer 2019'
        expect(result[0][:termIsSummer]).to eq true
        expect(result[0][:acadCareer]).to eq 'UGRD'
      end
      it 'memoizes enrollment terms data' do
        expect(CampusSolutions::MyEnrollmentTerms).to receive(:get_terms).once.and_return(my_enrollment_terms)
        result1 = subject.get_active_career_terms
        result2 = subject.get_active_career_terms
        expect(result1.first[:termId]).to eq '2195'
        expect(result2.first[:termId]).to eq '2195'
      end
    end
    context 'when enrollment terms are not available' do
      let(:my_enrollment_terms) { nil }
      it 'returns empty array' do
        expect(result).to eq([])
      end
    end
  end

  describe '#parse_early_drop_deadline_classes' do
    let(:instruction) do
      {
        enrolledClasses: [
          {
            edd: 'Y',
            subjectCatalog: 'MATH 1A',
            title: 'CALCULUS',
          },
          {
            edd: 'N',
            subjectCatalog: 'COLWRIT R1A',
            title: 'COLLEGE WRITING 1A',
          },
          {
            edd: 'Y',
            subjectCatalog: 'PSYCH 1',
            title: 'GENERAL PSYCHOLOGY',
          },
          {
            edd: 'Y',
            subjectCatalog: 'PSYCH 1',
            title: 'GENERAL PSYCHOLOGY',
          },
        ]
      }
    end
    it 'adds early drop deadline class list' do
      subject.parse_early_drop_deadline_classes(instruction)
      expect(instruction[:earlyDropDeadlineClasses]).to eq 'MATH 1A, PSYCH 1'
    end
    context 'when no early drop deadline classes are present' do
      before { instruction[:enrolledClasses].each {|c| c[:edd] = 'N' } }
      it 'sets early drop deadline class list as nil' do
        subject.parse_early_drop_deadline_classes(instruction)
        expect(instruction[:earlyDropDeadlineClasses]).to eq nil
      end
    end
  end
end
