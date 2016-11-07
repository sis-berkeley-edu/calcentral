describe HubEdos::AcademicStatus do
  subject { proxy.get }
  let(:student_feed) { subject[:feed]['student'] }

  context 'mock proxy' do
    context 'successful response' do
      let(:proxy) { HubEdos::AcademicStatus.new(fake: true, user_id: '61889') }
      it_should_behave_like 'a simple proxy that returns errors'

      it 'includes academic data' do
        expect(student_feed).to include 'academicStatuses'
        expect(student_feed).to include 'awardHonors'
        expect(student_feed).to include 'degrees'
        expect(student_feed).to include 'holds'
      end

      it 'omits superfluous data' do
        expect(student_feed).not_to include 'identifiers'
        expect(student_feed).not_to include 'names'
      end

      it 'returns academic status with expected structure' do
        status = student_feed['academicStatuses'][0]
        expect(status['cumulativeGPA']['average']).to eq 3.8
        expect(status['cumulativeUnits'].find{ |units| units['type']['code'] == 'Total' }['unitsPassed']).to eq 73
        expect(status['currentRegistration']['academicCareer']['description']).to eq 'Undergraduate'
        expect(status['studentCareer']['academicCareer']['description']).to eq 'Undergraduate'
        expect(status['studentPlans'][0]['academicPlan']['academicProgram']['academicCareer']['code']).to eq 'UGRD'
        expect(status['studentPlans'][0]['academicPlan']['academicProgram']['program']['description']).to eq 'Undergrad Letters & Science'
        expect(status['studentPlans'][0]['academicPlan']['academicProgram']['program']['description']).to eq 'Undergrad Letters & Science'
        expect(status['studentPlans'][0]['academicPlan']['ownedBy']['administrativeOwners'][0]['organization']['description']).to eq 'English'
        expect(status['studentPlans'][0]['academicPlan']['plan']['description']).to eq 'English BA'
        expect(status['studentPlans'][0]['primary']).to eq true
        expect(status['studentPlans'][0]['expectedGraduationTerm']['id']).to eq '2202'
        expect(status['studentPlans'][0]['expectedGraduationTerm']['name']).to eq '2020 Spring'
        expect(status['termsInAttendance']).to eq 4
      end
    end

    context 'failed response' do
      let(:proxy) { HubEdos::AcademicStatus.new(fake: true, user_id: '61889') }
      before do
        proxy.set_response({
          status: 503,
          body: ''
        })
      end
      it 'returns error' do
        expect(subject[:errored]).to eq true
        expect(subject[:statusCode]).to eq 503
        expect(subject[:body]).to eq 'An unknown server error occurred'
      end
    end

  end

  context 'real proxy', testext: true do
    let(:proxy) { HubEdos::AcademicStatus.new(fake: false, user_id: '242881') }
    before { allow_any_instance_of(CalnetCrosswalk::ByUid).to receive(:lookup_campus_solutions_id).and_return '17154428' }

    it 'returns known data with expected structure' do
      expect(student_feed['degrees'][0]['academicDegree']['type']['description']).to eq 'Doctor of Philosophy'
    end
  end
end
