describe MyAcademics::MyAcademicStatus do

  subject { described_class.new(random_id) }

  describe '#get_feed_internal' do
    let(:result) { subject.get_feed_internal }
    let(:academic_status_proxy) { double(:academic_status_proxy, :get => academic_status_response) }
    let(:academic_status_response) { nil }
    before { allow(HubEdos::StudentApi::V2::AcademicStatuses).to receive(:new).and_return(academic_status_proxy) }

    context 'when AcademicStatus response is nil' do
      let(:academic_status_response) { nil }
      it 'returns nil' do
        expect(result).to be nil
      end
    end
    context 'when AcademicStatus response is empty' do
      let(:academic_status_response) { {} }
      it 'returns an empty response' do
        expect(result).to eq({})
      end
    end
    context 'when AcademicStatus response is populated' do
      let(:academic_status_proxy) { HubEdos::StudentApi::V2::AcademicStatuses.new(fake: true, user_id: '61889') }
      it 'should successfully return a response' do
        expect(result[:statusCode]).to eq 200
      end
    end
  end

  describe '#process_career' do
    let(:status) do
      {
        'studentCareer' => {
          'academicCareer' => {
            'code' => 'GRAD',
            'description' => 'Graduate',
            'formalDescription' => 'Graduate'
          }
        }
      }
    end
    before { allow_any_instance_of(described_class).to receive(:career_based_role).and_return(:grad) }
    it 'adds career role to career object' do
      subject.process_career(status)
      expect(status['studentCareer'][:role]).to eq :grad
    end
  end

  describe '#process_plans' do
    let(:program_code) { 'UCLS' }
    let(:plan_status_code) { 'AC' }
    let(:status) do
      {
        'studentPlans' => [
          {
            'academicPlan' => {
              'academicProgram' => {
                'program' => {
                  'code' => program_code,
                  'description' => 'program description',
                  'formalDescription' => 'formal program description'
                }
              },
              'plan' => {
                'code' => '1001AWE'
              }
            },
            'statusInPlan' => {
              'status' => {
                'code' => plan_status_code
              }
            }
          }
        ]
      }
    end
    let(:result) {  }
    context 'when plan is active' do
      let(:plan_status_code) { 'AC' }
      before do
        expect(subject).to receive(:plan_based_roles).once.and_return(['beAwesome'])
        expect(subject).to receive(:program_based_role).once.and_return(['lettersAndScience', 'degreeSeeking'])
      end
      it 'appends plan roles' do
        subject.process_plans(status)
        expect(status['studentPlans'][0][:role]).to eq ['beAwesome']
      end
      it 'appends program roles' do
        subject.process_plans(status)
        expect(status['studentPlans'][0]['academicPlan']['academicProgram'][:role]).to eq ['lettersAndScience', 'degreeSeeking']
      end
    end
    context 'when a plan is inactive' do
      let(:plan_status_code) { 'DC' }
      it 'does not append plan roles' do
        subject.process_plans(status)
        expect(status['studentPlans'][0].has_key?(:role)).to eq false
      end
      it 'does not append program roles' do
        subject.process_plans(status)
        expect(status['studentPlans'][0]['academicPlan']['academicProgram'].has_key?(:role)).to eq false
      end
    end
  end

  describe '#career_based_role' do
    let(:student_career_code) { 'GRAD' }
    let(:student_career) do
      {
        'academicCareer' => {
          'code' => student_career_code,
          'description' => 'career description',
          'formalDescription' => 'formal career description'
        }
      }
    end
    let(:result) { subject.career_based_role(student_career) }
    context 'when no career code present' do
      let(:student_career_code) { nil }
      it 'returns nil' do
        expect(result).to eq nil
      end
    end
    context 'when career code is present' do
      let(:student_career_code) { 'UGRD' }
      context 'when career roles found for career code' do
        let(:career_roles) { ['ugrd', 'grad'] }
        before { allow(subject).to receive(:get_academic_career_roles).and_return(career_roles) }
        it 'returns first career role' do
          expect(result).to eq 'ugrd'
        end
      end
    end
  end

  describe '#assign_roles' do
    subject { academic_statuses }
    before do
      described_class.new(random_id).assign_roles(academic_statuses)
    end
    let(:career) do
      {
        'academicCareer' => { 'code' => 'UGRD' }
      }
    end
    let(:plan) do
      {
        'academicPlan' => {
          'plan' => { 'code' => '25000FPFU' },
          'academicProgram' => program
        },
        'statusInPlan' => plan_status
      }
    end
    let(:program) do
      {
        'program' => { 'code' => 'UCLS' }
      }
    end

    context 'when academic_statuses is empty' do
      let(:academic_statuses) { [] }
      it 'does not assign roles' do
        expect(subject).to eq []
      end
    end
    context 'when student has no career, plan, or program' do
      let(:academic_statuses) { [ {} ] }
      it 'does not assign roles' do
        expect(subject).to eq [ {} ]
      end
    end
    context 'when plans list and career are nil' do
      let(:academic_statuses) do
        [
          {
            'studentCareer' => nil,
            'studentPlans' => nil
          }
        ]
      end
      it 'does not assign roles' do
        expect(subject.first['studentPlans']).to be nil
      end
    end
    context 'when plans list is empty' do
      let(:academic_statuses) do
        [
          { 'studentPlans' => [] }
        ]
      end
      it 'does not assign roles' do
        expect(subject.first['studentPlans']).to eq []
      end
    end
    context 'when student has inactive plan' do
      let(:plan_status) { { 'status' => { 'code' => 'CM' } } }
      let(:academic_statuses) do
        [
          {
            'studentPlans' => [ plan ]
          }
        ]
      end
      it 'does not assign roles' do
        expect(subject.first['studentPlans'].first[:role]).to be nil
      end
    end
    context 'when student has active plan-based, program-based, and career-based roles' do
      let(:plan_status) { { 'status' => { 'code' => 'AC' } } }
      let(:academic_statuses) do
        [
          {
            'studentCareer' => career,
            'studentPlans' => [ plan ]
          }
        ]
      end
      it 'assigns roles' do
        expect(subject.first['studentCareer'][:role]).to eq 'ugrd'
        expect(subject.first['studentPlans'].first[:role]).to eq ['fpf']
        expect(subject.first['studentPlans'].first['academicPlan']['academicProgram'][:role]).to eq 'lettersAndScience'
      end
    end

    context 'when student has an active plan code that maps to multiple plan-based roles' do
      let(:master_of_laws_status) do
        {
          'studentCareer' => {
            'academicCareer' => {
              'code' => 'LAW',
              'description' => 'Law',
              'formalDescription' => 'Law',
              'fromDate' => '2017-08-14',
              'toDate' => '2018-05-09'
            },
            'matriculation' => {
              'term' => {
                'id' => '2178',
                'name' => '2017 Fall'
              },
              'type' => {
                'code' => 'FYR',
                'description' => 'First Year Student'
              }
            },
            'fromDate' => '2017-08-14',
            'toDate' => '2018-05-09'
          },
          'studentPlans' => [
            {
              'academicPlan' => {
                'plan' => {
                  'code' => '845B0LLMG',
                  'description' => 'Master of Laws LLM',
                  'fromDate' => '2017-08-25',
                  'toDate' => '2018-05-09'
                },
                'type' => {
                  'code' => 'SS',
                  'description' => 'Major - Self-Supporting'
                },
                'cipCode' => '22.0202',
                'hegisCode' => '',
                'targetDegree' => {
                  'type' => {
                    'code' => '28',
                    'description' => 'Master of Laws'
                  }
                },
                'ownedBy' => {
                  'administrativeOwners' => [
                    {
                      'organization' => {
                        'code' => 'LAW',
                        'description' => 'School of Law'
                      },
                      'percentage' => 100
                    }
                  ]
                },
                'academicProgram' => {
                  'program' => {
                    'code' => 'LSSDP',
                    'description' => 'Law Self-Supporting Programs'
                  },
                  'academicCareer' => {
                    'code' => 'LAW',
                    'description' => 'Law',
                    'formalDescription' => 'Law',
                    'fromDate' => '2017-08-14',
                    'toDate' => '2018-05-09'
                  }
                }
              },
              'statusInPlan' => {
                'status' => {
                  'code' => 'AC',
                  'description' => 'Active in Program'
                },
                'action' => {
                  'code' => 'DATA',
                  'description' => 'Data Change'
                },
                'reason' => {
                  'code' => 'GTOI',
                  'description' => 'Grad Term - Auto Opt-In'
                }
              },
              'primary' => true,
              'expectedGraduationTerm' => {}
            }
          ]
        }
      end
      let(:academic_statuses) { [master_of_laws_status] }
      it 'returns all applicable roles' do
        expect(subject.first['studentPlans'].first[:role]).to include('lawJdLlm', 'masterOfLawsLlm')
      end
    end
  end

  context '#status_code' do
    let(:feed) { {:statusCode => 200 } }
    let(:result) { subject.status_code }
    before { allow(subject).to receive(:get_feed).and_return(feed) }
    it 'returns api feed status code' do
      expect(result).to eq 200
    end
  end

  context '#errored?' do
    let(:feed) { {:errored => true } }
    let(:result) { subject.errored? }
    before { allow(subject).to receive(:get_feed).and_return(feed) }
    it 'returns api feed error boolean' do
      expect(result).to eq true
    end
  end

  context '#error_message' do
    let(:feed) { {:errored => error_status, :body => 'SOMETHING BROKE'} }
    let(:result) { subject.error_message }
    before { allow(subject).to receive(:get_feed).and_return(feed) }
    context 'when feed has not errored' do
      let(:error_status) { false }
      it 'returns nil' do
        expect(result).to eq nil
      end
    end
    context 'when feed has errored' do
      let(:error_status) { true }
      it 'returns body' do
        expect(result).to eq 'SOMETHING BROKE'
      end
    end
  end

  context '#academic_statuses' do
    let(:feed) do
      {
        'academicStatuses' => [
          {'studentCareer' => 'student_career_data1'},
          {'studentCareer' => 'student_career_data2'},
        ]
      }
    end
    let(:result) { subject.academic_statuses }
    before { allow(subject).to receive(:feed).and_return(feed) }
    it 'returns academic statuses from feed' do
      expect(result[0]['studentCareer']).to eq 'student_career_data1'
      expect(result[1]['studentCareer']).to eq 'student_career_data2'
    end
  end

  context '#holds' do
    let(:feed) { {'holds' => [{'type' => 'hold_type'}]} }
    let(:result) { subject.holds }
    before { allow(subject).to receive(:feed).and_return(feed) }
    it 'returns holds from feed' do
      expect(result[0]['type']).to eq 'hold_type'
    end
    context 'when no holds available' do
      let(:feed) { {} }
      it 'returns empty array' do
        expect(result).to eq([])
      end
    end
  end

  context '#award_honors' do
    let(:feed) { {'awardHonors' => ['honor1','honor2']} }
    let(:result) { subject.award_honors }
    before { allow(subject).to receive(:feed).and_return(feed) }
    it 'returns award honors from feed' do
      expect(result).to eq(['honor1','honor2'])
    end
  end

  context '#degrees' do
    let(:feed) { {'degrees' => ['degree1','degree2']} }
    let(:result) { subject.degrees }
    before { allow(subject).to receive(:feed).and_return(feed) }
    it 'returns degrees from feed' do
      expect(result).to eq(['degree1','degree2'])
    end
  end

  context '#max_terms_in_attendance' do
    let(:result) { subject.max_terms_in_attendance }
    before { allow(subject).to receive(:academic_statuses).and_return(academic_statuses) }
    context 'when no academic statuses are present' do
      let(:academic_statuses) { [] }
      it 'returns nil' do
        expect(result).to eq nil
      end
    end
    context 'when academic statuses are present' do
      let(:academic_statuses) do
        [
          {'termsInAttendance' => 5},
          {'termsInAttendance' => 8},
          {'termsInAttendance' => 2},
        ]
      end
      it 'returns maximum count' do
        expect(result).to eq 8
      end
    end
  end

  describe 'class methods' do
    let(:statuses) { [] }
    let(:holds) { [] }
    let(:feed) { {'academicStatuses' => statuses} }
    let(:mocked_instance) { double(:my_academic_status, feed: feed, academic_statuses: statuses, holds: holds) }
    before { allow(described_class).to receive(:new).and_return(mocked_instance) }

    describe '.statuses_by_career_role' do
      let(:career_role_matchers) { ['ugrd'] }
      let(:statuses) do
        [
          { 'studentCareer' => {'academicCareer' => {'code' => 'UGRD'}, role: 'ugrd'} },
          { 'studentCareer' => {'academicCareer' => {'code' => 'GRAD'}, role: 'grad'} },
          { 'studentCareer' => {'academicCareer' => {'code' => 'LAW'}, role: 'law'} },
        ]
      end
      subject { described_class.statuses_by_career_role(random_id, career_role_matchers) }
      context 'when statuses are empty' do
        let(:statuses) { [] }
        it 'returns empty array' do
          expect(subject).to eq []
        end
      end
      context 'when career role matchers are empty' do
        let(:career_role_matchers) { [] }
        it 'returns empty array' do
          expect(subject).to eq []
        end
      end
      context 'when single career role matcher is specified' do
        let(:career_role_matchers) { ['grad'] }
        it 'returns matching academic status' do
          expect(subject.count).to eq 1
          expect(subject[0]['studentCareer']['academicCareer']['code']).to eq 'GRAD'
        end
      end
      context 'when multiple career role matchers are specified' do
        let(:career_role_matchers) { ['ugrd','law'] }
        it 'returns matching academic statuses' do
          expect(subject.count).to eq 2
          expect(subject[0]['studentCareer']['academicCareer']['code']).to eq 'UGRD'
          expect(subject[1]['studentCareer']['academicCareer']['code']).to eq 'LAW'
        end
      end
    end

    describe '.active_plans(uid)' do
      subject { described_class.active_plans(random_id) }
      context 'when statuses is nil' do
        let(:statuses) { nil }
        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end
      context 'when statuses is empty' do
        let(:statuses) { [] }
        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end
      context 'when student plans are empty' do
        let(:statuses) do
          [
            {'studentPlans' => []},
            {'studentPlans' => []}
          ]
        end
        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end
      context 'when no active plans present' do
        let(:statuses) do
          [
            {
              'studentPlans' => [
                {'statusInPlan' => {'status' => {'code' => 'DC'}}},
                {'statusInPlan' => {'status' => {'code' => 'DC'}}},
              ]
            },
            {
              'studentPlans' => [
                {'statusInPlan' => {'status' => {'code' => 'DC'}}},
              ]
            },
          ]
        end
        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end
      context 'when active plans are present' do
        let(:statuses) do
          [
            {
              'studentPlans' => [
                {'plan' => {'description'=> 'plan 1'}, 'statusInPlan' => {'status' => {'code' => 'DC'}}},
                {'plan' => {'description'=> 'plan 2'}, 'statusInPlan' => {'status' => {'code' => 'AC'}}},
              ]
            },
            {
              'studentPlans' => [
                {'plan' => {'description'=> 'plan 3'}, 'statusInPlan' => {'status' => {'code' => 'AC'}}},
                {'plan' => {'description'=> 'plan 4'}, 'statusInPlan' => {'status' => {'code' => 'CP'}}},
              ]
            },
          ]
        end
        it 'returns an active plans' do
          expect(subject.count).to eq 2
          expect(subject[0]['plan']['description']).to eq 'plan 2'
          expect(subject[1]['plan']['description']).to eq 'plan 3'
        end
      end
    end

    describe '.careers' do
      let(:statuses) { [] }
      subject { described_class.careers(random_id) }

      context 'when statuses is nil' do
        let(:statuses) { nil }
        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end
      context 'when statuses is empty' do
        let(:statuses) { [] }
        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end
      context 'when career is not populated' do
        let(:statuses) do
          [
            {},
            { 'foo'=> 'bar '},
            { 'studentCareer'=> nil },
            { 'studentCareer'=> {} },
            { 'studentCareer'=> { 'academicCareer' => nil } }
          ]
        end
        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end
      context 'when career is populated' do
        let(:statuses) do
          [
            { 'studentCareer'=> { 'academicCareer' => 'CAREER1' } },
            { 'studentCareer'=> { 'academicCareer' => 'CAREER1' } },
            { 'studentCareer'=> { 'academicCareer' => 'CAREER2' } },
          ]
        end
        it 'returns a list of careers, excluding duplicates' do
          expect(subject).to eq ['CAREER1', 'CAREER2']
        end
      end
    end

    describe '.has_holds?' do
      subject { described_class.has_holds?(random_id) }
      context 'when holds is nil' do
        let(:holds) { nil }
        it 'returns false' do
          expect(subject).to eq false
        end
      end
      context 'when holds is not an array' do
        let(:holds) { 'garbage' }
        it 'returns false' do
          expect(subject).to eq false
        end
      end
      context 'when student has no holds' do
        let(:holds) { [] }
        it 'returns false' do
          expect(subject).to eq false
        end
      end
      context 'when student has holds' do
        let(:holds) { [ 1 ] }
        it 'returns true' do
          expect(subject).to eq true
        end
      end
    end
  end
end
