describe DegreeProgress::MyUndergradRequirements do
  subject { described_class.new(user_id) }
  let(:emplid) { 11667051 }
  let(:user_id) { 61889 }
  let(:feature_flag_enabled) { true }
  before do
    proxy_class = CampusSolutions::DegreeProgress::UndergradRequirements
    fake_proxy = proxy_class.new(user_id: user_id, fake: true)
    allow(proxy_class).to receive(:new).and_return fake_proxy
    allow(Settings.features).to receive(:cs_degree_progress_ugrd_student).and_return(feature_flag_enabled)
  end

  describe '#get_feed_internal' do
    let(:flag) { :cs_degree_progress_ugrd_student }
    subject { described_class.new(user_id).get_feed_internal }

    it_behaves_like 'a proxy that observes a feature flag'
    it_behaves_like 'a proxy that returns undergraduate milestone data'

    context 'when student is active in the Letters and Science program' do
      before do
        allow(MyAcademics::MyAcademicStatus).to receive(:statuses_by_career_role).with(user_id, ['ugrd']).and_return(academic_statuses)
      end
      let(:academic_statuses) do
        [
          {
            'studentPlans' => [
              {
                'academicPlan'=> {
                  'academicProgram'=> {
                    'program'=> {
                      'code'=> 'UCLS'
                    }
                  }
                },
                'statusInPlan'=> {
                  'status'=> {
                    'code'=> 'AC'
                  }
                }
              }
            ]
          }
        ]
      end
      it 'includes the Academic Progress Report link in the response' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:academicProgressReport]).to be
        expect(subject[:feed][:links][:academicProgressReport][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SAA_SS_DPR_ADB.GBL?EMPLID=11667051'
      end
    end
    context 'when student is active in the Undergraduate College of Engineering' do
      before do
        allow(MyAcademics::MyAcademicStatus).to receive(:statuses_by_career_role).with(user_id, ['ugrd']).and_return(academic_statuses)
      end
      let(:academic_statuses) do
        [
          {
            'studentPlans' => [
              {
                'academicPlan'=> {
                  'academicProgram'=> {
                    'program'=> {
                      'code'=> 'UCOE'
                    }
                  }
                },
                'statusInPlan'=> {
                  'status'=> {
                    'code'=> 'AC'
                  }
                }
              }
            ]
          }
        ]
      end
      it 'includes the Academic Progress Report link in the response' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:academicProgressReport]).to be
        expect(subject[:feed][:links][:academicProgressReport][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SAA_SS_DPR_ADB.GBL?EMPLID=11667051'
      end
    end
    context 'when student is active in the Undergraduate Environmental Design program' do
      before do
        allow(MyAcademics::MyAcademicStatus).to receive(:statuses_by_career_role).with(user_id, ['ugrd']).and_return(academic_statuses)
      end
      let(:academic_statuses) do
        [
          {
            'studentPlans' => [
              {
                'academicPlan'=> {
                  'academicProgram'=> {
                    'program'=> {
                      'code'=> 'UCED'
                    }
                  }
                },
                'statusInPlan'=> {
                  'status'=> {
                    'code'=> 'AC'
                  }
                }
              }
            ]
          }
        ]
      end
      it 'does includes the Academic Progress Report link in the response' do
        expect(subject[:feed][:links][:academicProgressReport]).to be
        expect(subject[:feed][:links][:academicProgressReport][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SAA_SS_DPR_ADB.GBL?EMPLID=11667051'
      end
    end
    context 'when student is not active in the Letters and Science program' do
      before do
        allow(MyAcademics::MyAcademicStatus).to receive(:statuses_by_career_role).with(user_id, ['ugrd']).and_return(academic_statuses)
      end
      let(:academic_statuses) do
        [
          {
            'studentPlans' => [
              {
                'academicPlan'=> {
                  'academicProgram'=> {
                    'program'=> {
                      'code'=> 'XXXX'
                    }
                  }
                },
                'statusInPlan'=> {
                  'status'=> {
                    'code'=> 'AC'
                  }
                }
              }
            ]
          }
        ]
      end
      it 'does not include the Academic Progress Report link in the response' do
        expect(subject[:feed][:links]).not_to be
      end
    end

  end

  describe '#should_see_links?' do
    let(:result) { subject.should_see_links? }
    before do
      allow(MyAcademics::MyAcademicStatus).to receive(:statuses_by_career_role).with(user_id, ['ugrd']).and_return(academic_statuses)
    end
    let(:academic_statuses) do
      [
        {
          'studentPlans' => [
            {
              'academicPlan'=> {
                'academicProgram'=> {
                  'program'=> {
                    'code'=> ugrd_role
                  }
                }
              },
              'statusInPlan'=> {
                'status'=> {
                  'code'=> ugrd_program_status_code
                }
              }
            }
          ]
        }
      ]
    end
    let(:ugrd_role) { 'XXXX' }
    let(:ugrd_program_status_code) { 'CM' }
    let(:ugrd_natural_resources_apr_feature_flag) { false }
    before do
      allow(Settings.features).to receive(:cs_degree_progress_ugrd_ucnr_apr_link).and_return(ugrd_natural_resources_apr_feature_flag)
    end
    context 'when student has no matching role' do
      it 'returns false' do
        expect(result).to eq false
      end
    end
    context 'when student has matching role but all completed programs' do
      let(:ugrd_role) { 'UCLS' }
      let(:ugrd_program_status_code) { 'CM' }
      it 'returns false' do
        expect(result).to eq false
      end
    end
    context 'when student is in undergraduate letters and science program' do
      let(:ugrd_role) { 'UCLS' }
      let(:ugrd_program_status_code) { 'AC' }
      it 'returns true' do
        expect(result).to eq true
      end
    end
    context 'when student is in undergraduate engineering program' do
      let(:ugrd_role) { 'UCOE' }
      let(:ugrd_program_status_code) { 'AC' }
      it 'returns true' do
        expect(result).to eq true
      end
    end
    context 'when student is in undergraduate environmental design program' do
      let(:ugrd_role) { 'UCED' }
      let(:ugrd_program_status_code) { 'AC' }
      it 'returns true' do
        expect(result).to eq true
      end
    end
    context 'when student is in undergraduate haas business program' do
      let(:ugrd_role) { 'UBUS' }
      let(:ugrd_program_status_code) { 'AC' }
      it 'returns true' do
        expect(result).to eq true
      end
    end
    context 'when student is in undergraduate natural resources program' do
      let(:ugrd_role) { 'UCNR' }
      let(:ugrd_program_status_code) { 'AC' }
      context 'when APR link for UCNR students feature flag is on' do
        let(:ugrd_natural_resources_apr_feature_flag) { true }
        it 'returns true' do
          expect(result).to eq true
        end
      end
      context 'when APR Link for UNCR students feature flag is off' do
        let(:ugrd_natural_resources_apr_feature_flag) { false }
        it 'returns false' do
          expect(result).to eq false
        end
      end
    end
  end

  describe '#get_incomplete_programs_roles' do
    let(:result) { subject.get_incomplete_programs_roles }
    before do
      allow(MyAcademics::MyAcademicStatus).to receive(:statuses_by_career_role).with(user_id, ['ugrd']).and_return(academic_statuses)
    end
    let(:academic_statuses) do
      [
        {
          'studentPlans' => [
            {
              'academicPlan'=> {
                'academicProgram'=> {
                  'program'=> {
                    'code'=> ugrd_role
                  }
                }
              },
              'statusInPlan'=> {
                'status'=> {
                  'code'=> ugrd_program_status_code
                }
              }
            }
          ]
        }
      ]
    end
    let(:ugrd_role) { 'XXXX' }
    let(:ugrd_program_status_code) { 'CM' }
    context 'when no academic statuses are returned' do
      let(:academic_statuses) { nil }
      it 'returns []' do
        expect(result).to eq []
      end
    end
    context 'when academic statuses returns incomplete data' do
      let(:academic_statuses) do
        [
          {
            'studentPlans' => [
              {
                'primary'=> false
              }
            ]
          }
        ]
      end
      it 'returns []' do
        expect(result).to eq []
      end
    end
    context 'when academic statuses returned valid but completed program' do
      let(:ugrd_role) { 'UCED' }
      let(:ugrd_program_status_code) { 'CM' }
      it 'returns []' do
        expect(result).to eq []
      end
    end
    context 'when academic statuses returned valid program' do
      let(:ugrd_role) { 'UCED' }
      let(:ugrd_program_status_code) { 'AC' }
      it 'returns valid program role' do
        expect(result).to eq ['UCED']
      end
    end
  end

end
