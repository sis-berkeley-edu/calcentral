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
        expect(roles['law']).to eq has_law_career
        expect(roles['concurrent']).to eq false
        expect(roles['lettersAndScience']).to eq has_ucls_program
        expect(roles['haasFullTimeMba']).to eq false
        expect(roles['haasEveningWeekendMba']).to eq false
        expect(roles['haasExecMba']).to eq false
        expect(roles['haasMastersFinEng']).to eq false
        expect(roles['haasMbaPublicHealth']).to eq false
        expect(roles['haasMbaJurisDoctor']).to eq false
        expect(roles['ugrdUrbanStudies']).to eq false
        expect(roles['summerVisitor']).to eq has_summer_visitor_plan
        expect(roles['courseworkOnly']).to eq has_coursework_only_plan
      end

      it 'maps a plan-based role onto the corresponding plan' do
        academic_statuses = subject[:feed]['student']['academicStatuses']
        academic_statuses.each do |status|
          first_plan = status['studentPlans'].try(:[], 0)
          second_plan = status['studentPlans'].try(:[], 1)

          expect(first_plan[:role]).to be nil if first_plan && !has_summer_visitor_plan
          expect(first_plan[:role]).to eq 'summerVisitor' if first_plan && has_summer_visitor_plan

          expect(second_plan[:role]).to be nil if second_plan && !has_coursework_only_plan
          expect(second_plan[:role]).to eq 'courseworkOnly' if second_plan && has_coursework_only_plan
        end
      end

      it 'maps a career-based role onto the corresponding career' do
        academic_statuses = subject[:feed]['student']['academicStatuses']
        academic_statuses.each do |status|
          expect(status['studentCareer'][:role]).to be nil unless has_law_career
          expect(status['studentCareer'][:role]).to eq 'law' if has_law_career
        end
      end
    end

    before do
      allow_any_instance_of(HubEdos::AcademicStatus).to receive(:get).and_return academic_status_response
    end

    let(:academic_status_response) do
      {
        'statusCode' => 200,
        :feed => feed,
        'studentNotFound' => nil
      }
    end
    let(:roles) do
      {
        'fpf' => false,
        'ugrd' => true
      }
    end
    let(:feed) { {'student' => student} }
    let(:student) do
      {
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

    let(:has_summer_visitor_plan) { false }
    let(:has_coursework_only_plan) { false }
    let(:has_law_career) { false }
    let(:has_ucls_program) { false }

    context 'when student has no career and no plans' do
      it_behaves_like 'a translator that maps academic status to roles'
    end

    context 'when student has a career that maps to a role' do
      let(:has_law_career) { true }
      let(:academic_career) {
        {
          'code' => 'LAW',
          'description' => 'Bob Loblaw\'s Law Blog'
        }
      }
      context 'when student has no plans' do
        it_behaves_like 'a translator that maps academic status to roles'
      end

      context 'when student has a plan that doesn\'t map to a role' do
        let(:academic_plans) {
          [academic_plan_generic]
        }
        it_behaves_like 'a translator that maps academic status to roles'
      end

      context 'when student has a plan that maps to a role' do
        let(:has_summer_visitor_plan) { true }
        let(:academic_plans) {
          [academic_plan_summer_visitor]
        }
        it_behaves_like 'a translator that maps academic status to roles'
      end

      context 'when student has multiple plans that map to a role' do
        let(:has_summer_visitor_plan) { true }
        let(:has_coursework_only_plan) { true }
        let(:academic_plans) {
          [academic_plan_summer_visitor, academic_plan_coursework_only]
        }
        it_behaves_like 'a translator that maps academic status to roles'
      end
    end

    context 'when student has a summer visitor plan' do
      let(:has_summer_visitor_plan) { true }
      let(:academic_plans) {
        [academic_plan_summer_visitor]
      }
      it_behaves_like 'a translator that maps academic status to roles'

      context 'when student has another plan that doesn\'t map to a role' do
        let(:academic_plans) {
          [academic_plan_summer_visitor, academic_plan_generic]
        }
        it_behaves_like 'a translator that maps academic status to roles'
      end
    end

    context 'when student has a coursework-only plan but is not active in the plan' do
      let(:has_coursework_only_plan) { false }
      let(:academic_plans) {
        [academic_plan_not_active]
      }
      it_behaves_like 'a translator that maps academic status to roles'
    end

    context 'when student is active in the UCLS program' do
      let(:has_ucls_program) { true }
      let(:academic_plans) {
        [academic_program_ucls]
      }
      it_behaves_like 'a translator that maps academic status to roles'
    end

    context 'when student is in the UCLS program but is not active' do
      let(:has_ucls_program) { false }
      let(:academic_plans) {
        [academic_program_not_active]
      }
      it_behaves_like 'a translator that maps academic status to roles'
    end

    context 'get roles' do
      subject { described_class.get_roles(random_id) }
      before { allow_any_instance_of(described_class).to receive(:get_feed_internal).and_return(response_with_merged_student_roles) }
      let(:response_with_merged_student_roles) do
        academic_status_response[:feed]['student']['roles'] = roles
        academic_status_response
      end
      context 'no feed' do
        let(:response_with_merged_student_roles) { nil }
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
      context 'no student present' do
        let(:response_with_merged_student_roles) { {feed: {}} }
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
      context 'student with roles present' do
        it 'returns roles' do
          expect(subject['fpf']).to eq false
          expect(subject['ugrd']).to eq true
        end
      end
    end

    context 'get statuses' do
      before { allow_any_instance_of(described_class).to receive(:get_feed_internal).and_return(academic_status_response) }
      subject { described_class.get_statuses(random_id) }
      context 'no feed' do
        let(:academic_status_response) { nil }
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
      context 'academic statuses present in feed' do
        it 'returns academic statuses' do
          expect(subject.count).to eq 1
          expect(subject[0]['studentCareer']).to be
          expect(subject[0]['studentPlans']).to be
          expect(subject[0]['currentRegistration']).to be
        end
      end
    end

    context 'get careers' do
      before { allow_any_instance_of(described_class).to receive(:get_feed_internal).and_return(academic_status_response) }
      subject { described_class.get_careers(random_id) }
      context 'no feed' do
        let(:academic_status_response) { nil }
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
      context 'careers present in academic statuses' do
        let(:academic_career) {
          {
            'code' => 'LAW',
            'description' => 'Bob Loblaw\'s Law Blog'
          }
        }
        it 'returns careers' do
          expect(subject.count).to eq 1
          expect(subject[0]['code']).to eq 'LAW'
          expect(subject[0]['description']).to eq 'Bob Loblaw\'s Law Blog'
        end
      end
    end
  end
end
