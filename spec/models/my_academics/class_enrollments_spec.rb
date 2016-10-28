describe MyAcademics::ClassEnrollments do
  let(:student_uid) { '123456' }
  let(:student_emplid) { '12000001' }
  let(:is_feature_enabled_flag) { true }
  let(:user_is_student) { false }
  let(:cs_enrollment_career_terms_feed) do
    {
      statusCode: 200,
      feed: {
        enrollmentTerms: cs_enrollment_career_terms,
        studentId: student_emplid
      }
    }
  end
  let(:cs_enrollment_term_detail_feed) do
    {
      statusCode: 200,
      feed: {
        enrollmentTerm: {
          studentId: student_emplid,
          term: '216X',
          termDescr: 'Afterlithe 2016',
          isClassScheduleAvailable: true,
          isGradeBaseAvailable: false,
          links: {},
          advisors: [],
          enrollmentPeriod: [],
          scheduleOfClassesPeriod: {},
          enrolledClasses: [],
          waitlistedClasses: [],
          enrolledClassesTotalUnits: 8.0,
          waitlistedClassesTotalUnits: 2.0,
        }
      }
    }
  end
  let(:college_and_level_feed) do
    {
      collegeAndLevel: {
        statusCode: 200,
        studentNotFound: nil,
        holds: college_and_level_holds,
        careers: ["Undergraduate"],
        level: "Senior",
        termName: "Fall 2016",
        termsInAttendance: "3",
        majors: college_and_level_majors,
        minors: college_and_level_minors,
        plans: college_and_level_plans,
        lastExpectedGraduationTerm: college_and_level_last_expected_grad_term,
        isCurrent: true
      }
    }
  end
  let(:college_and_level_holds) { { hasHolds: false } }
  let(:college_and_level_majors) { [undergrad_nutritional_science_major] }
  let(:college_and_level_minors) { [] }
  let(:college_and_level_last_expected_grad_term) { { code: nil, description: nil, name: nil} }
  let(:college_and_level_plans) { [undergrad_nutritional_science_plan] }
  let(:undergrad_nutritional_science_major) do
    {:college=>"Undergrad Natural Resources", :major=>"Nutritional Science BS"}
  end
  let(:undergrad_nutritional_science_plan) do
    {
      career: { code: "UGRD", description: "Undergraduate" },
      program: { code: "UCNR", description: "Undergrad Natural Resources" },
      plan: { code: "04606U", description: "Nutritional Science BS" },
      type: { code: "MAJ", description: "Major - Regular Acad/Prfnl", category: "Major" },
      college: "Undergrad Natural Resources",
      role: "default",
      enrollmentRole: "default",
      primary: true,
    }
  end
  let(:undergrad_computer_science_plan) do
    {
      career: { code: "UGRD", description: "Undergraduate" },
      program: { code: "UCLS", description: "Undergrad Letters & Science" },
      plan: { code: "25201U", description: "Computer Science BA" },
      type: { code: "MAJ", description: "Major - Regular Acad/Prfnl", category: "Major" },
      college: "Undergrad Letters & Science",
      role: "default",
      enrollmentRole: "default",
      primary: true,
    }
  end
  let(:undergrad_cognitive_science_plan) do
    {
      career: { code: "UGRD", description: "Undergraduate" },
      program: { code: "UCLS", description: "Undergrad Letters & Science" },
      plan: { code: "25179U", description: "Cognitive Science BA" },
      type: { code: "MAJ", description: "Major - Regular Acad/Prfnl", category: "Major"},
      college: "Undergrad Letters & Science",
      role: "default",
      enrollmentRole: "default",
      primary: true,
    }
  end
  let(:undergrad_fall_program_for_freshmen_plan) do
    {
      career: { code: "UGRD", description: "Undergraduate" },
      program: { code: "UCLS", description: "Undergrad Letters & Science" },
      plan: { code: "25000FPFU", description: "L&S Undcl Fall Pgm Freshmen UG" },
      type: { code: "MAJ", description: "Major - Regular Acad/Prfnl", category: "Major"},
      college: "Undergrad Letters & Science",
      role: "fpf",
      enrollmentRole: "fpf",
      primary: true,
    }
  end
  let(:graduate_electrical_engineering_plan) do
    {
      career: { code: "GRAD", description: "Graduate" },
      program: { code: "GACAD", description: "Graduate Academic Programs" },
      plan: { code: "16290PHDG", description: "Electrical Eng & Comp Sci PhD" },
      type: { code: "MAJ", description: "Major - Regular Acad/Prfnl", category: "Major" },
      college: "Graduate Academic Programs",
      role: "default",
      enrollmentRole: "default",
      primary: true,
    }
  end
  let(:law_jsp_plan) do
    {
      career: { code: "LAW", description: "Law" },
      program: { code: "LACAD", description: "Law Academic Programs" },
      plan: { code: "84485PHDG", description: "JSP PhD" },
      type: { code: "MAJ", description: "Major - Regular Acad/Prfnl", category: "Major" },
      college: "Law Academic Programs",
      role: "law",
      enrollmentRole: "law",
      primary: true,
    }
  end
  let(:cs_enrollment_career_terms) { [cs_career_term_ugrd_summer_2016, cs_career_term_grad_fall_2016, cs_career_term_law_fall_2016] }
  let(:cs_career_term_ugrd_summer_2016) { { termId: '2165', termDescr: '2016 Summer', acadCareer: 'UGRD' } }
  let(:cs_career_term_ugrd_fall_2016) { { termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' } }
  let(:cs_career_term_ugrd_spring_2017) { { termId: '2172', termDescr: '2017 Spring', acadCareer: 'UGRD' } }

  let(:cs_career_term_grad_fall_2016) { { termId: '2168', termDescr: '2016 Fall', acadCareer: 'GRAD' } }
  let(:cs_career_term_law_fall_2016) { { termId: '2168', termDescr: '2016 Fall', acadCareer: 'LAW' } }

  subject { MyAcademics::ClassEnrollments.new(student_uid) }
  before do
    allow(subject).to receive(:is_feature_enabled).and_return(is_feature_enabled_flag)
    allow(subject).to receive(:user_is_student?).and_return(user_is_student)
    allow_any_instance_of(MyAcademics::CollegeAndLevel).to receive(:merge) do |feed_hash|
      feed_hash.merge!(college_and_level_feed)
    end
    allow_any_instance_of(CampusSolutions::EnrollmentTerms).to receive(:get).and_return(cs_enrollment_career_terms_feed)
    allow_any_instance_of(CampusSolutions::EnrollmentTerm).to receive(:get).and_return(cs_enrollment_term_detail_feed)
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
      let(:college_and_level_plans) { [undergrad_computer_science_plan] }
      let(:cs_enrollment_career_terms) { [{ termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' }] }
      let(:user_is_student) { true }
      let(:feed) { subject.get_feed }
      it 'include enrollment instruction types' do
        types = feed[:enrollmentTermInstructionTypes]
        expect(types.count).to eq 1
        expect(types[0][:role]).to eq 'default'
        expect(types[0][:careerCode]).to eq 'UGRD'
        expect(types[0][:academicPlans].count).to eq 1
        expect(types[0][:term][:termId]).to eq '2168'
        expect(types[0][:term][:termDescr]).to eq '2016 Fall'
      end
      it 'includes enrollment instructions for each active term' do
        instructions = feed[:enrollmentTermInstructions]
        expect(instructions.keys.count).to eq 1
        expect(instructions[:'2168'][:studentId]).to eq student_emplid
        expect(instructions[:'2168'][:term]).to eq '216X'
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
        expect(feed[:links].count).to be 3
        expect(feed[:links][:ucAddClassEnrollment]).to be
        expect(feed[:links][:ucEditClassEnrollment]).to be
        expect(feed[:links][:ucViewClassEnrollment]).to be
      end
    end
  end

  context 'when determining the users hold status' do
    let(:user_holds_status) { subject.user_has_holds? }
    context 'when no holds present' do
      let(:college_and_level_holds) { { hasHolds: false } }
      it 'should return false' do
        expect(user_holds_status).to eq false
      end
    end
    context 'when holds are present' do
      let(:college_and_level_holds) { { hasHolds: true } }
      it 'should return true' do
        expect(user_holds_status).to eq true
      end
    end
  end

  context 'when grouping student plans by role' do
    let(:student_plan_roles) { subject.grouped_student_plan_roles }
    let(:college_and_level_plans) { [undergrad_computer_science_plan, graduate_electrical_engineering_plan, law_jsp_plan] }
    it 'groups plans by role and career code' do
      expect(student_plan_roles[:data]).to have_keys([ ['default','UGRD'], ['default','GRAD'], ['law','LAW'] ])
    end
    it 'includes role code with each student plan role' do
      expect(student_plan_roles[:data][['default','UGRD']][:role]).to eq 'default'
      expect(student_plan_roles[:data][['default','GRAD']][:role]).to eq 'default'
      expect(student_plan_roles[:data][['law','LAW']][:role]).to eq 'law'
    end
    it 'includes career code with each student plan role' do
      expect(student_plan_roles[:data][['default','UGRD']][:career_code]).to eq 'UGRD'
      expect(student_plan_roles[:data][['default','GRAD']][:career_code]).to eq 'GRAD'
      expect(student_plan_roles[:data][['law','LAW']][:career_code]).to eq 'LAW'
    end
    it 'includes plans with each student plan role' do
      expect(student_plan_roles[:data][['default','UGRD']][:academic_plans].count).to eq 1
      expect(student_plan_roles[:data][['default','GRAD']][:academic_plans].count).to eq 1
      expect(student_plan_roles[:data][['law','LAW']][:academic_plans].count).to eq 1
      expect(student_plan_roles[:data][['default','UGRD']][:academic_plans][0][:plan][:code]).to eq '25201U'
      expect(student_plan_roles[:data][['default','GRAD']][:academic_plans][0][:plan][:code]).to eq '16290PHDG'
      expect(student_plan_roles[:data][['law','LAW']][:academic_plans][0][:plan][:code]).to eq '84485PHDG'
    end
    it 'includes metadata for included plans' do
      expect(student_plan_roles[:metadata][:includes_fpf]).to eq false
    end
  end

  context 'when providing career term roles' do
    let(:career_term_roles) { subject.get_career_term_roles }
    let(:cs_enrollment_career_terms) do
      [
        { termId: '2165', termDescr: '2016 Summer', acadCareer: 'UGRD' },
        { termId: '2168', termDescr: '2016 Fall', acadCareer: 'GRAD' },
        { termId: '2168', termDescr: '2016 Fall', acadCareer: 'LAW' }
      ]
    end
    context 'when multiple student plan roles match a career code for an active career-term' do
      let(:college_and_level_plans) { [undergrad_computer_science_plan, undergrad_cognitive_science_plan, law_jsp_plan] }
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
      let(:college_and_level_plans) { [law_jsp_plan] }
      let(:cs_enrollment_career_terms) {
        [
          { termId: '2168', termDescr: '2016 Fall', acadCareer: 'LAW' },
          { termId: '2172', termDescr: '2017 Spring', acadCareer: 'LAW' },
        ]
      }
      it 'includes the plans for each matching career-term' do
        expect(career_term_roles.count).to eq 2
        expect(career_term_roles[0][:academic_plans].count).to eq 1
        expect(career_term_roles[0][:academic_plans][0][:plan][:code]).to eq '84485PHDG'
        expect(career_term_roles[0][:term][:termId]).to eq '2168'
        expect(career_term_roles[0][:term][:termDescr]).to eq '2016 Fall'
        expect(career_term_roles[1][:academic_plans].count).to eq 1
        expect(career_term_roles[1][:academic_plans][0][:plan][:code]).to eq '84485PHDG'
        expect(career_term_roles[1][:term][:termId]).to eq '2172'
        expect(career_term_roles[1][:term][:termDescr]).to eq '2017 Spring'
      end
    end

    context 'when a student plan role does not match the career code for any active career-term' do
      let(:college_and_level_plans) { [law_jsp_plan] }
      let(:cs_enrollment_career_terms) { [{ termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' }] }
      it 'does not include an career term role object for the student plan role' do
        expect(career_term_roles.count).to eq 0
      end
    end

    context 'when a student plan role is fpf and matches multiple career-terms' do
      let(:college_and_level_plans) { [undergrad_fall_program_for_freshmen_plan] }
      let(:cs_enrollment_career_terms) { [
        { termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' },
        { termId: '2172', termDescr: '2017 Spring', acadCareer: 'UGRD' },
        { termId: '2175', termDescr: '2017 Summer', acadCareer: 'UGRD' },
      ] }
      it 'applies the fpf role to the earliest career term role object' do
        expect(career_term_roles.count).to eq 3
        expect(career_term_roles[0][:role]).to eq 'fpf'
        expect(career_term_roles[0][:career_code]).to eq 'UGRD'
        expect(career_term_roles[0][:academic_plans].count).to eq 1
        expect(career_term_roles[0][:academic_plans][0][:plan][:code]).to eq '25000FPFU'
        expect(career_term_roles[0][:term][:termId]).to eq '2168'
      end
      it 'applies a default fpf role to the later career term role objects' do
        expect(career_term_roles[1][:role]).to eq 'default'
        expect(career_term_roles[1][:career_code]).to eq 'UGRD'
        expect(career_term_roles[1][:academic_plans].count).to eq 1
        expect(career_term_roles[1][:academic_plans][0][:plan][:code]).to eq '25000FPFU'
        expect(career_term_roles[1][:term][:termId]).to eq '2172'
        expect(career_term_roles[2][:role]).to eq 'default'
        expect(career_term_roles[2][:career_code]).to eq 'UGRD'
        expect(career_term_roles[2][:academic_plans].count).to eq 1
        expect(career_term_roles[2][:academic_plans][0][:plan][:code]).to eq '25000FPFU'
        expect(career_term_roles[2][:term][:termId]).to eq '2175'
      end
    end

    context 'when a student plan roles are fpf and default and both match multiple career-terms' do
      let(:college_and_level_plans) { [undergrad_fall_program_for_freshmen_plan, undergrad_nutritional_science_plan] }
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
        expect(career_term_roles[1][:term][:termId]).to eq '2172'
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
            expect(term_detail[:term]).to eq '216X'
            expect(term_detail[:termDescr]).to eq 'Afterlithe 2016'
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

  context 'when providing active career term data' do
    context 'when active terms are not returned' do
      let(:cs_enrollment_career_terms) { [] }
      it 'returns empty array' do
        expect(subject.get_active_career_terms).to eq []
      end
    end

    context 'when active terms are returned in non-chronological order' do
      let(:cs_enrollment_career_terms) { [cs_career_term_ugrd_fall_2016, cs_career_term_ugrd_spring_2017, cs_career_term_ugrd_summer_2016] }
      it 'returns active terms in order of term ID' do
        result = subject.get_active_career_terms
        expect(result.count).to eq 3
        expect result[0][:termId] = '2165'
        expect result[1][:termId] = '2168'
        expect result[2][:termId] = '2172'
      end
    end

    context 'when active terms are returned' do
      context 'when providing career terms' do
        it 'returns active terms for each career' do
          results = subject.get_active_career_terms
          expect(results.count).to eq 3
          expect results[0][:termId] = '2165'
          expect results[0][:termDescr] = '2016 Summer'
          expect results[0][:acadCareer] = 'UGRD'
          expect results[1][:termId] = '2168'
          expect results[1][:termDescr] = '2016 Fall'
          expect results[1][:acadCareer] = 'GRAD'
          expect results[2][:termId] = '2168'
          expect results[2][:termDescr] = '2016 Fall'
          expect results[2][:acadCareer] = 'LAW'
        end
      end

      context 'when providing unique term ids' do
        it 'provides unique term codes for active career terms' do
          result = subject.get_active_term_ids
          expect(result.count).to eq 2
          expect(result[0]).to eq '2165'
          expect(result[1]).to eq '2168'
        end
      end
    end

    context 'when no active terms are returned' do
      let(:cs_enrollment_career_terms) { [] }
      context 'when providing career terms' do
        it 'returns no active career terms' do
          expect(subject.get_active_career_terms).to eq []
        end
      end

      context 'when providing unique terms' do
        it 'provides empty array for active term ids' do
          expect(subject.get_active_term_ids).to eq []
        end
      end
    end
  end

end
