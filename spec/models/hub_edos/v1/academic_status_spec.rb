describe HubEdos::V1::AcademicStatus do
  subject { proxy.get }
  let(:student_feed) { subject[:feed]['student'] }

  context 'mock proxy' do
    let(:proxy) { HubEdos::V1::AcademicStatus.new(fake: true, user_id: random_id) }

    context 'successful response' do
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

      it 'returns degrees with expected structure' do
        degrees = student_feed['degrees']
        expect(degrees.count).to eq 4

        degrees.each do |degree|
          expect(degree['academicDegree']).to be
          expect(degree['academicDegree']['type']).to be
          expect(degree['academicDegree']['type']['code']).to be
          expect(degree['academicDegree']['type']['description']).to be

          expect(degree['completionTerm']).to be
          expect(degree['completionTerm']['name']).to be

          academicPlans = degree['academicPlans']
          expect(academicPlans).to be
          academicPlans.each do |academicPlan|
            expect(academicPlan['plan']).to be
            expect(academicPlan['plan']['code']).to be
            expect(academicPlan['plan']['description']).to be
            expect(academicPlan['plan']['formalDescription']).to be

            expect(academicPlan['type']).to be
            expect(academicPlan['type']['code']).to be
            expect(academicPlan['type']['description']).to be
            expect(academicPlan['type']['formalDescription']).to be

            expect(academicPlan['academicProgram']).to be
            expect(academicPlan['academicProgram']['program']).to be
            expect(academicPlan['academicProgram']['program']['code']).to be
            expect(academicPlan['academicProgram']['program']['description']).to be
            expect(academicPlan['academicProgram']['program']['formalDescription']).to be
            expect(academicPlan['academicProgram']['academicGroup']).to be
            expect(academicPlan['academicProgram']['academicGroup']['code']).to be
            expect(academicPlan['academicProgram']['academicGroup']['description']).to be
            expect(academicPlan['academicProgram']['academicGroup']['formalDescription']).to be
            expect(academicPlan['academicProgram']['academicCareer']).to be
            expect(academicPlan['academicProgram']['academicCareer']['code']).to be
            expect(academicPlan['academicProgram']['academicCareer']['description']).to be
            expect(academicPlan['academicProgram']['academicCareer']['formalDescription']).to be
            expect(academicPlan['academicProgram']['academicCareer']['fromDate']).to be
          end
        end
      end
    end

    context 'failed response' do
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
end
