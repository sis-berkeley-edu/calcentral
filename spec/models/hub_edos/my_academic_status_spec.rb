describe HubEdos::MyAcademicStatus do

  subject { described_class.new(random_id).get_feed_internal }

  context 'when calling a mock proxy' do
    it 'should successfully return a response' do
      expect(subject[:statusCode]).to eq 200
    end
  end

  context 'when calling a stubbed proxy' do
    shared_examples 'a translator that maps academic status to roles' do
      it 'translates roles' do
        roles = subject[:feed]['student']['roles']
        expect(roles).to be
        expect(roles.keys.count).to eq 15
        expect(roles['ugrd']).to eq false
        expect(roles['grad']).to eq false
        expect(roles['fpf']).to eq false
        expect(roles['law']).to eq has_law_role
        expect(roles['concurrent']).to eq false
        expect(roles['lettersAndScience']).to eq has_ucls_role
        expect(roles['haasFullTimeMba']).to eq false
        expect(roles['haasEveningWeekendMba']).to eq false
        expect(roles['haasExecMba']).to eq false
        expect(roles['haasMastersFinEng']).to eq false
        expect(roles['haasMbaPublicHealth']).to eq false
        expect(roles['haasMbaJurisDoctor']).to eq false
        expect(roles['ugrdUrbanStudies']).to eq false
        expect(roles['summerVisitor']).to eq has_summer_visitor_role
        expect(roles['courseworkOnly']).to eq has_coursework_only_role
      end
    end

    before do
      allow_any_instance_of(HubEdos::AcademicStatus).to receive(:get).and_return academic_status_response
    end

    let(:academic_status_response) do
      {
        'statusCode' => 200,
        :feed => {
          'student' => {
            'academicStatuses' => [
              {
                'studentCareer' => {
                  'academicCareer' => academic_career,
                  'fromDate' => '2011-05-23'
                },
                'studentPlans' => academic_plans,
                'currentRegistration' => {
                  'term' => {
                    'id' => '2115',
                    'name' => '2011 Summer'
                  },
                  'academicCareer' => {
                    'code' => 'UGRD',
                    'description' => 'Undergraduate'
                  },
                  'eligibleToRegister' => false,
                  'registered' => false,
                  'disabled' => false,
                  'athlete' => false,
                  'intendsToGraduate' => false,
                  'academicLevel' => {
                    'type' => {
                      'code' => 'Self Reported'
                    },
                    'level' => {
                      'code' => '',
                      'description' => ''
                    }
                  },
                  'termUnits' => [],
                  'termGPA' => {},
                  'new' => true
                }
              }
            ],
            'holds' => [],
            'awardHonors' => [],
            'degrees' => []
          }
        },
        'studentNotFound' => nil
      }
    end
    let(:academic_plans) {
      []
    }
    let(:academic_career) {
      nil
    }
    let(:academic_plan_generic) {
      {
        'academicPlan' => {
          'plan' => {
            'code' => '12345AB',
            'description' => 'Plan Not Tied To Any Role',
            'fromDate' => '2011-05-23'
          },
          'academicProgram' => {
            'program' => {},
          }
        },
        'statusInPlan' => {
          'status' => {
            'code' => 'AC',
            'description' => 'Active in Program'
          }
        },
      }
    }
    let(:academic_plan_summer_visitor) {
      {
        'academicPlan' => {
          'plan' => {
            'code' => '99000U',
            'description' => 'Summer Domestic Visitor UG',
            'fromDate' => '2011-05-23'
          },
          'academicProgram' => {
            'program' => {},
          }
        },
        'statusInPlan' => {
          'status' => {
            'code' => 'AC',
            'description' => 'Active in Program'
          }
        }
      }
    }
    let(:academic_plan_coursework_only) {
      {
        'academicPlan' => {
          'plan' => {
            'code' => '00975CWOG',
            'description' => 'Integrative Biology CWO',
            'fromDate' => '2011-05-23'
          },
          'academicProgram' => {
            'program' => {},
          }
        },
        'statusInPlan' => {
          'status' => {
            'code' => 'AC',
            'description' => 'Active in Program'
          }
        }
      }
    }
    let(:academic_plan_not_active) {
      {
        'academicPlan' => {
          'plan' => {
            'code' => '70141MBAG',
            'description' => 'Business Administration MBA',
            'fromDate' => '2011-05-23'
          },
          'academicProgram' => {
            'program' => {},
          }
        },
        'statusInPlan' => {
          'status' => {
            'code' => 'CM',
            'description' => 'Completed Program'
          }
        }
      }
    }
    let(:academic_program_ucls) {
      {
        'academicPlan' => {
          'plan' => {
            'code' => '25246U',
            'description' => 'Economics BA',
            'fromDate' => '2011-05-23'
          },
          'academicProgram' => {
            'program' => {
              'code' => 'UCLS',
              'description' => 'Undergrad Letters & Science'
            },
          }
        },
        'statusInPlan' => {
          'status' => {
            'code' => 'AC',
            'description' => 'Active In Program'
          }
        }
      }
    }
    let(:academic_program_not_active) {
      {
        'academicPlan' => {
          'plan' => {
            'code' => '25246U',
            'description' => 'Economics BA',
            'fromDate' => '2011-05-23'
          },
          'academicProgram' => {
            'program' => {
              'code' => 'UCLS',
              'description' => 'Undergrad Letters & Science'
            },
          }
        },
        'statusInPlan' => {
          'status' => {
            'code' => 'CM',
            'description' => 'Completed Program'
          }
        }
      }
    }

    let(:has_summer_visitor_role) { false }
    let(:has_coursework_only_role) { false }
    let(:has_law_role) { false }
    let(:has_ucls_role) { false }

    context 'when student has no career and no plans' do
      it_behaves_like 'a translator that maps academic status to roles'
    end

    context 'when student has a law career' do
      let(:academic_career) {
        {
          'code' => 'LAW',
          'description' => 'Bob Loblaw\'s Law Blog'
        }
      }
      context 'when student has no plans' do
        it_behaves_like 'a translator that maps academic status to roles'
      end

      context 'when student has a plan' do
        let(:has_law_role) { true }
        let(:academic_plans) {
          [academic_plan_generic]
        }
        it_behaves_like 'a translator that maps academic status to roles'
      end
    end

    context 'when student has a summer visitor plan' do
      let(:has_summer_visitor_role) { true }
      let(:academic_plans) {
        [academic_plan_summer_visitor]
      }
      it_behaves_like 'a translator that maps academic status to roles'
    end

    context 'when student has a coursework-only plan' do
      let(:has_coursework_only_role) { true }
      let(:academic_plans) {
        [academic_plan_coursework_only]
      }
      it_behaves_like 'a translator that maps academic status to roles'
    end

    context 'when student has a coursework-only plan but is not active in the plan' do
      let(:has_coursework_only_role) { false }
      let(:academic_plans) {
        [academic_plan_not_active]
      }
      it_behaves_like 'a translator that maps academic status to roles'
    end

    context 'when student is active in the UCLS program' do
      let(:has_ucls_role) { true }
      let(:academic_plans) {
        [academic_program_ucls]
      }
      it_behaves_like 'a translator that maps academic status to roles'
    end

    context 'when student is in the UCLS program but is not active' do
      let(:has_ucls_role) { false }
      let(:academic_plans) {
        [academic_program_not_active]
      }
      it_behaves_like 'a translator that maps academic status to roles'
    end

    context 'get roles' do
      let(:feed) do
        {
          feed: {
            'student' => student
          }
        }
      end
      subject { described_class.get_roles(random_id) }
      before { allow_any_instance_of(described_class).to receive(:get_feed_internal).and_return(feed) }
      context 'no feed' do
        let(:feed) { nil }
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
      context 'no student present' do
        let(:student) { nil }
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
      context 'student with roles present' do
        let(:student) do
          {
            'roles' => {
              'fpf' => false
            }
          }
        end
        it 'returns roles' do
          expect(subject['fpf']).to eq false
        end
      end
    end

  end
end
