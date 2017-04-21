describe MyAcademics::AcademicPlan do

  let(:uid) { random_id }
  let(:user_cs_id) { random_id }
  let(:fake) { true }

  let(:plan_proxy) { CampusSolutions::AdvisingAcademicPlan.new(user_id: uid, fake: fake) }
  let(:attribute_proxy) { HubEdos::StudentAttributes.new(user_id: uid, fake: fake) }
  let(:semesters_data) {
    { semesters: [
      {
        :name => 'Fall 2016',
        :slug => 'fall-2016',
        :termCode => 'D',
        :termYear => '2016',
        :timeBucket => 'current',
        :campusSolutionsTerm => true,
        :gradingInProgress => nil,
        :classes => [
          {
            course_code: 'EDUC 75AC',
            sections: [
              {
                is_primary_section: true,
                units: '3.0'
              },
              {
                is_primary_section: false,
                units: '3.0'
              }]

          }],
        :hasEnrollmentData => true,
        :summaryFromTranscript => false,
        :hasEnrolledClasses => true
      },
      {
        :name => 'Fall 2017',
        :slug => 'fall-2017',
        :termCode => 'D',
        :termYear => '2017',
        :timeBucket => 'future',
        :campusSolutionsTerm => true,
        :gradingInProgress => nil,
        :classes => [
          {
            course_code: 'INTEGBI C82',
            sections: [
              {
                is_primary_section: true,
                waitlisted: true,
                units: '4.0',
                waitlistPosition: '3'
              }]
          },
          {
            course_code: 'EDUC 75AC',
            sections: [
              {
                is_primary_section: true,
                units: '2.0'
              },
              {
                is_primary_section: true,
                units: '3.0'
              }
            ]
          }],
        :hasEnrollmentData => true,
        :summaryFromTranscript => false,
        :hasEnrolledClasses => true
      }
    ]
    }
  }

  let(:arch_attribute) { nil }
  let(:student_attributes) do
    [
      get_attribute('+REG', 'Officially Registered', 'REG', 'You are officially registered for this term and may access campus services.'),
      get_attribute('+S09', 'Tuition Calculated', 'TCALC', 'Tuition and fees have been calculated for the term.'),
      arch_attribute
    ]
  end
  let(:attribute_proxy_response_json) do
    {
      apiResponse: {
        correlationId: "954511bf-fd38-4aef-ad9f-2525d4005407",
        response: {
          any: {
            students: [
              {
                affiliations: [],
                confidential: false,
                identifiers: [],
                studentAttributes: student_attributes.compact,
              }
            ]
          }
        },
        responseType: "http://bmeta.berkeley.edu/student/studentV0.xsd/students",
        source: "UCB-SIS-STUDENT"
      }
    }.to_json
  end

  before do
    attribute_proxy.set_response({
      status: 200,
      headers: {'Content-Type' => 'application/json'},
      body: attribute_proxy_response_json
    })
    allow(CampusSolutions::AdvisingAcademicPlan).to receive(:get).and_return(plan_proxy)
    allow(HubEdos::StudentAttributes).to receive(:new).and_return(attribute_proxy)
    allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: uid).and_return(
      double(lookup_campus_solutions_id: user_cs_id))
  end

  subject do
    semesters_data.tap {|x| MyAcademics::AcademicPlan.new(uid).merge(x)}
  end

  context 'when grading returns statuses for a teaching semester' do

    it 'it should combine the planned and enrolled semesters sorted' do
      expect(subject[:planSemesters].length).to eq 3
      expect(subject[:planSemesters][0][:edoId]).to eq '2168'
      expect(subject[:planSemesters][1][:edoId]).to eq '2172'
      expect(subject[:planSemesters][2][:edoId]).to eq '2178'
    end

    it 'it should parse enrolled semesters correctly' do
      expect(subject[:planSemesters][0][:enrolledClasses].length).to eq 1
      expect(subject[:planSemesters][1][:enrolledClasses]).to be_nil
      expect(subject[:planSemesters][2][:enrolledClasses].length).to eq 2
    end

    it 'it should parse planned semesters correctly' do
      expect(subject[:planSemesters][0][:plannedClasses].length).to eq 1
      expect(subject[:planSemesters][1][:plannedClasses].length).to eq 2
      expect(subject[:planSemesters][2][:plannedClasses].length).to eq 0
    end

    it 'it should parse hasWaitlisted flag correctly' do
      expect(subject[:planSemesters][0][:hasWaitlisted]).to eq false
      expect(subject[:planSemesters][1][:hasWaitlisted]).to eq false
      expect(subject[:planSemesters][2][:hasWaitlisted]).to eq true
    end

    it 'it should calc plannedUnits correctly' do
      expect(subject[:planSemesters][0][:plannedUnits]).to eq '3.0'
      expect(subject[:planSemesters][1][:plannedUnits]).to eq '7.0'
      expect(subject[:planSemesters][2][:plannedUnits]).to eq '0.0'
    end

    it 'it should calc enrolledUnits correctly' do
      expect(subject[:planSemesters][0][:enrolledUnits]).to eq '3.0'
      expect(subject[:planSemesters][1][:enrolledUnits]).to eq '0.0'
      expect(subject[:planSemesters][2][:enrolledUnits]).to eq '5.0'
    end

    it 'it should calc waitlistedunits correctly' do
      expect(subject[:planSemesters][0][:waitlistedUnits]).to eq '0.0'
      expect(subject[:planSemesters][1][:waitlistedUnits]).to eq '0.0'
      expect(subject[:planSemesters][2][:waitlistedUnits]).to eq '4.0'
    end
  end

  context 'legacy report status' do
    context 'when student has no archived academic records prior to 1995' do
      let(:arch_attribute) { nil }
      it 'includes the reason code and message' do
        expect(subject[:legacyReportStatus][:code]).to eq 'NONE'
        expect(subject[:legacyReportStatus][:message]).to eq 'Legacy report not present'
        expect(subject[:legacyReportStatus][:link]).to eq nil
      end
    end

    context 'when student has only archived academic records prior to 1995' do
      let(:reason_code) { 'ARCH' }
      let(:reason_description) { 'This student has a historic academic summary report. Use the link below to view the April 30th, 2017 snapshot of this student\'s record.' }
      let(:arch_attribute) { get_attribute('+R11', 'Archived Transcript Processing', reason_code, reason_description) }
      it 'includes the reason code and message' do
        expect(subject[:legacyReportStatus][:code]).to eq reason_code
        expect(subject[:legacyReportStatus][:message]).to eq reason_description
        expect(subject[:legacyReportStatus][:link][:url]).to eq "https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/UC_SR_TSCRPT.UC_SR_TSCRP.GBL?UC_CTS_EMPLID8=#{user_cs_id}"
      end
    end

    context 'when student both pre and post 1995 academic records' do
      let(:reason_code) { 'BOTH' }
      let(:reason_description) { 'This student has a historic summary report as well as recent records. Use the link below to view the April 30th, 2017 snapshot of this student\'s record.' }
      let(:arch_attribute) { get_attribute('+R11', 'Archived Transcript Processing', reason_code, reason_description) }
      it 'includes the reason code and message' do
        expect(subject[:legacyReportStatus][:code]).to eq reason_code
        expect(subject[:legacyReportStatus][:message]).to eq reason_description
        expect(subject[:legacyReportStatus][:link][:url]).to eq "https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/UC_SR_TSCRPT.UC_SR_TSCRP.GBL?UC_CTS_EMPLID8=#{user_cs_id}"
      end
    end
  end

  def get_attribute(type_code, type_desc, reason_code, reason_desc)
    {
      comments: '',
      fromDate: '2017-04-30',
      reason: {
        code: reason_code,
        description: 'some description',
        formalDescription: reason_desc
      },
      type: {
        code: type_code,
        description: type_desc
      }
    }
  end

end
