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
  let(:edo_hub_academic_status_feed) do
    {
      statusCode: 200,
      feed: {
        'student' => {
          'academicStatuses' => [{'studentPlans' => student_plans}],
        }
      }
    }
  end
  let(:cs_enrollment_career_terms) do
    [
      { termId: '2165', termDescr: '2016 Summer', acadCareer: 'UGRD' },
      { termId: '2168', termDescr: '2016 Fall', acadCareer: 'GRAD' },
      { termId: '2168', termDescr: '2016 Fall', acadCareer: 'LAW' }
    ]
  end
  let(:cs_holds_feed) do
    {"statusCode"=>200, "feed"=>{"serviceIndicators"=>service_indicators}}.to_json
  end
  let(:service_indicators) { [] }
  let(:student_plans) { [] }
  let(:compsci_ugrd_plan) do
    student_plan({
      career_code: 'UGRD',
      career_description: 'Undergraduate',
      program_code: 'UCLS',
      program_description: 'Undergrad Letters & Science',
      plan_code: '25201U',
      plan_description: 'Computer Science BA',
    })
  end
  let(:cogsci_ugrd_plan) do
    student_plan({
      career_code: 'UGRD',
      career_description: 'Undergraduate',
      program_code: 'UCLS',
      program_description: 'Undergrad Letters & Science',
      plan_code: '25179U',
      plan_description: 'Cognitive Science BA',
    })
  end
  let(:eleng_grad_plan) do
    student_plan({
      career_code: 'GRAD',
      career_description: 'Graduate',
      program_code: 'GACAD',
      program_description: 'Graduate Academic Programs',
      plan_code: '16290PHDG',
      plan_description: 'Electrical Eng & Comp Sci PhD',
    })
  end
  let(:public_health_grad_plan) do
    student_plan({
      career_code: 'GRAD',
      career_description: 'Graduate',
      program_code: 'GPRFL',
      program_description: 'Graduate Professional Programs',
      plan_code: '96789PHBAG',
      plan_description: 'Public Health MPH-MBA CDP',
    })
  end
  let(:business_admin_mba_haas_plan) do
    student_plan({
      career_code: 'GRAD',
      career_description: 'Graduate',
      program_code: 'GPRFL',
      program_description: 'Graduate Professional Programs',
      plan_code: '70141BAPHG',
      plan_description: 'Business Admin MBA-MPH CDP',
    })
  end
  let(:jsp_law_plan) do
    student_plan({
      career_code: 'LAW',
      career_description: 'Law',
      program_code: 'LACAD',
      program_description: 'Law Academic Programs',
      plan_code: '84485PHDG',
      plan_description: 'JSP PhD',
    })
  end
  def student_plan(cpp_hash)
    {
      "academicPlan"=>{
        "plan"=>{
          "code"=>cpp_hash[:plan_code],
          "description"=>cpp_hash[:plan_description]
        },
        "academicProgram"=>{
          "program"=>{
            "code"=>cpp_hash[:program_code],
            "description"=>cpp_hash[:program_description]
          },
          "academicCareer"=>{
            "code"=>cpp_hash[:career_code],
            "description"=>cpp_hash[:career_description]
          }
        }
      },
      "primary"=>(cpp_hash[:is_primary] || true)
    }
  end
  subject { MyAcademics::ClassEnrollments.new(student_uid) }
  before do
    allow(subject).to receive(:is_feature_enabled).and_return(is_feature_enabled_flag)
    allow(subject).to receive(:user_is_student?).and_return(user_is_student)
    allow_any_instance_of(CampusSolutions::MyHolds).to receive(:get_feed).and_return(cs_holds_feed)
    allow_any_instance_of(HubEdos::AcademicStatus).to receive(:get).and_return(edo_hub_academic_status_feed)
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
      let(:student_plans) { [compsci_ugrd_plan] }
      let(:cs_enrollment_career_terms) { [{ termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' }] }
      let(:user_is_student) { true }
      it 'include enrollment instruction types' do
        result = subject.get_feed
        types = result[:enrollmentTermInstructionTypes]
        expect(types.count).to eq 1
        expect(types[0][:instructionTypeCode]).to eq 'default'
        expect(types[0][:careerCode]).to eq 'UGRD'
        expect(types[0][:academicPlans].count).to eq 1
        expect(types[0][:term][:termId]).to eq '2168'
        expect(types[0][:term][:termDescr]).to eq '2016 Fall'
      end
      it 'includes enrollment instructions for each active term' do
        result = subject.get_feed
        instructions = result[:enrollmentTermInstructions]
        expect(instructions.keys.count).to eq 1
        expect(instructions[:'2168'][:studentId]).to eq student_emplid
        expect(instructions[:'2168'][:term]).to eq '216X'
      end
      it 'includes academic planner data for each term' do
        result = subject.get_feed
        plans = result[:enrollmentTermAcademicPlanner]
        expect(plans.keys.count).to eq 1
        expect(plans[:'2168']).to have_key(:studentId)
        expect(plans[:'2168'][:updateAcademicPlanner][:name]).to eq 'Update'
        expect(plans[:'2168'][:academicplanner].count).to eq 1
      end
      it 'includes users hold status' do
        result = subject.get_feed
        expect(result[:hasHolds]).to eq false
      end
    end
  end

  context 'when providing active student plans' do
    let(:student_plans) { [business_admin_mba_haas_plan, public_health_grad_plan] }
    it 'returns plans that include career code and description' do
      active_plans = subject.get_active_plans
      expect(active_plans.count).to eq 2
      active_plans.each do |plan|
        expect(plan[:career][:code]).to eq 'GRAD'
        expect(plan[:career][:description]).to eq 'Graduate'
      end
    end

    it 'returns plans that include plan code and description' do
      active_plans = subject.get_active_plans
      expect(active_plans.count).to eq 2
      expect(active_plans[0][:plan][:code]).to eq '70141BAPHG'
      expect(active_plans[0][:plan][:description]).to eq 'Business Admin MBA-MPH CDP'
      expect(active_plans[1][:plan][:code]).to eq '96789PHBAG'
      expect(active_plans[1][:plan][:description]).to eq 'Public Health MPH-MBA CDP'
    end
  end

  context 'when flattening a student academic plan' do
    it 'returns plan hash when input is empty' do
      result = subject.flatten_plan({})
      expect(result[:career][:code]).to eq nil
      expect(result[:career][:description]).to eq nil
      expect(result[:plan][:code]).to eq nil
      expect(result[:plan][:description]).to eq nil
    end

    it 'handles missing hash nodes gracefully' do
      business_admin_mba_haas_plan['academicPlan'].delete('academicProgram')
      result = subject.flatten_plan(business_admin_mba_haas_plan)
      expect(result[:career][:code]).to be_nil
      expect(result[:career][:description]).to be_nil
      expect(result[:plan][:code]).to eq '70141BAPHG'
      expect(result[:plan][:description]).to eq 'Business Admin MBA-MPH CDP'
    end
    it 'flattens academic status plan into cpp hash' do
      result = subject.flatten_plan(business_admin_mba_haas_plan)
      expect(result[:career][:code]).to eq 'GRAD'
      expect(result[:career][:description]).to eq 'Graduate'
      expect(result[:plan][:code]).to eq '70141BAPHG'
      expect(result[:plan][:description]).to eq 'Business Admin MBA-MPH CDP'
    end
  end

  context 'when defining enrollment instruction types' do
    it 'includes plans and career matchers' do
      expect(subject.class::ENROLLMENT_INSTRUCTION_TYPES[:plan].count).to_not eq 0
      expect(subject.class::ENROLLMENT_INSTRUCTION_TYPES[:career].count).to_not eq 0
    end

    it 'defines type code and match string for each matcher' do
      subject.class::ENROLLMENT_INSTRUCTION_TYPES.values_at(:plan, :career).flatten.each do |matcher|
        expect(matcher).to have_key(:instruction_type_code)
        expect(matcher).to have_key(:match)
      end
    end
  end

  context 'when determining the users hold status' do
    let(:user_holds_status) { subject.user_has_holds? }
    context 'when no service indicators present' do
      let(:service_indicators) { ['service_indicator'] }
      it 'should return true' do
        expect(user_holds_status).to eq true
      end
    end
    context 'when feed response fails' do
      let(:cs_holds_feed) { {"statusCode"=>500}.to_json }
      it 'should return false' do
        expect(user_holds_status).to eq false
      end
    end
    context 'when service indicators are present' do
      it 'should return false' do
        expect(user_holds_status).to eq false
      end
    end
  end

  context 'when providing enrollment term instruction types' do
    let(:term_instruction_types) { subject.get_enrollment_term_instruction_types }
    let(:cs_enrollment_career_terms) do
      [
        { termId: '2165', termDescr: '2016 Summer', acadCareer: 'UGRD' },
        { termId: '2168', termDescr: '2016 Fall', acadCareer: 'GRAD' },
        { termId: '2168', termDescr: '2016 Fall', acadCareer: 'LAW' }
      ]
    end
    context 'when multiple instruction types matches a career code for an active career-term' do
      let(:student_plans) { [compsci_ugrd_plan, cogsci_ugrd_plan, jsp_law_plan] }
      let(:cs_enrollment_career_terms) { [{ termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' }] }
      it 'excludes instruction type with non-matching career code' do
        expect(term_instruction_types.count).to eq 1
      end
      it 'includes multiple plans of the same type in the same career-term' do
        expect(term_instruction_types[0][:academic_plans].count).to eq 2
        plans = term_instruction_types[0][:academic_plans]
        plan_codes = plans.collect {|plan| plan[:plan][:code] }
        expect(plan_codes).to include('25201U', '25179U')
      end
      it 'includes term code and description' do
        expect(term_instruction_types[0][:term][:termId]).to eq '2168'
        expect(term_instruction_types[0][:term][:termDescr]).to eq '2016 Fall'
      end
    end

    context 'when an instruction type matches a career code for multiple active career-terms' do
      let(:student_plans) { [jsp_law_plan] }
      let(:cs_enrollment_career_terms) {
        [
          { termId: '2168', termDescr: '2016 Fall', acadCareer: 'LAW' },
          { termId: '2172', termDescr: '2017 Spring', acadCareer: 'LAW' },
        ]
      }
      it 'includes the plans for each matching career-term' do
        expect(term_instruction_types.count).to eq 2
        expect(term_instruction_types[0][:academic_plans].count).to eq 1
        expect(term_instruction_types[0][:academic_plans][0][:plan][:code]).to eq '84485PHDG'
        expect(term_instruction_types[0][:term][:termId]).to eq '2168'
        expect(term_instruction_types[1][:academic_plans].count).to eq 1
        expect(term_instruction_types[1][:academic_plans][0][:plan][:code]).to eq '84485PHDG'
        expect(term_instruction_types[1][:term][:termId]).to eq '2172'
      end
    end

    context 'when an instruction type does not match the career code for any active career-term' do
      let(:student_plans) { [jsp_law_plan] }
      let(:cs_enrollment_career_terms) { [{ termId: '2168', termDescr: '2016 Fall', acadCareer: 'UGRD' }] }
      it 'does not include an enrollment term instruction object for the instruction type' do
        expect(term_instruction_types.count).to eq 0
      end
    end
  end

  context 'when providing enrollment instruction plan types' do
    let(:instruction_types) { subject.get_enrollment_instruction_types }
    let(:student_plans) { [compsci_ugrd_plan, eleng_grad_plan, jsp_law_plan] }
    it 'groups plans by enrollment instruction type and career code' do
      expect(instruction_types).to have_keys([ ['default','UGRD'], ['default','GRAD'], ['law','LAW'] ])
    end
    it 'includes type code with each enrollment instruction type' do
      expect(instruction_types[['default','UGRD']][:instruction_type_code]).to eq 'default'
      expect(instruction_types[['default','GRAD']][:instruction_type_code]).to eq 'default'
      expect(instruction_types[['law','LAW']][:instruction_type_code]).to eq 'law'
    end
    it 'includes career code with each enrollment instruction type' do
      expect(instruction_types[['default','UGRD']][:career_code]).to eq 'UGRD'
      expect(instruction_types[['default','GRAD']][:career_code]).to eq 'GRAD'
      expect(instruction_types[['law','LAW']][:career_code]).to eq 'LAW'
    end
    it 'includes plans with each enrollment instruction type' do
      expect(instruction_types[['default','UGRD']][:academic_plans].count).to eq 1
      expect(instruction_types[['default','GRAD']][:academic_plans].count).to eq 1
      expect(instruction_types[['law','LAW']][:academic_plans].count).to eq 1
      expect(instruction_types[['default','UGRD']][:academic_plans][0][:plan][:code]).to eq '25201U'
      expect(instruction_types[['default','GRAD']][:academic_plans][0][:plan][:code]).to eq '16290PHDG'
      expect(instruction_types[['law','LAW']][:academic_plans][0][:plan][:code]).to eq '84485PHDG'
    end
  end

  context 'when determining the calcentral enrollment instruction type code' do
    it 'identifies a default plan in undergrad career' do
      plan = {
        career: { code: 'UGRD', description: 'Undergraduate' },
        plan: { code: '25699U', description: 'Political Science'}
      }
      expect(subject.get_enrollment_instruction_type_code(plan)).to eq 'default'
    end

    it 'identifies a default plan in graduate career' do
      plan = {
        career: { code: 'GRAD', description: 'Graduate' },
        plan: { code: '16290PHDG', description: 'Electrical Eng & Comp Sci PhD'}
      }
      expect(subject.get_enrollment_instruction_type_code(plan)).to eq 'default'
    end

    it 'identifies a berkeley law career plan' do
      plan = {
        career: { code: 'LAW', description: 'Law' },
        plan: { code: '842C1JSDG', description: 'Doctor of Science of Law JSD'}
      }
      expect(subject.get_enrollment_instruction_type_code(plan)).to eq 'law'
    end

    it 'identifies a concurrent enrollment plan' do
      plan = {
        career: { code: 'UCBX', description: 'UC Berkeley Extension' },
        plan: { code: '30XCECCENX', description: 'UCBX Concurrent Enrollment'}
      }
      expect(subject.get_enrollment_instruction_type_code(plan)).to eq 'ucbx'
    end

    it 'identifies a fall program for freshmen plan' do
      plan = {
        career: { code: 'UGRD', description: 'Undergraduate' },
        plan: { code: '25000FPFU', description: 'L&S Undcl Fall Pgm Freshmen UG'}
      }
      expect(subject.get_enrollment_instruction_type_code(plan)).to eq 'fpf'
    end

    it 'identifies a Haas Business School MBA plan' do
      plan = {
        career: { code: 'GRAD', description: 'Graduate' },
        plan: { code: '70141MBAG', description: 'Business Administration MBA'}
      }
      expect(subject.get_enrollment_instruction_type_code(plan)).to eq 'haas_mba'
    end

    it 'identifies a Haas Business School Evening and Weekend MBA plan' do
      plan = {
        career: { code: 'GRAD', description: 'Graduate' },
        plan: { code: '701E1MBAG', description: 'Berkeley MBA for Executives'}
      }
      expect(subject.get_enrollment_instruction_type_code(plan)).to eq 'haas_ewmba'
    end

    it 'identifies a Haas Business School Executive MBA plan' do
      plan = {
        career: { code: 'GRAD', description: 'Graduate' },
        plan: { code: '70364MBAG', description: 'Berkeley MBA for Executives'}
      }
      expect(subject.get_enrollment_instruction_type_code(plan)).to eq 'haas_execmba'
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

      context 'when providing unique terms' do
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
