describe MyAcademics::EnrollmentVerification do
  let(:uid) { random_id }
  let(:feed) { subject.get_feed }
  let(:roles) { {'ugrd' => true, 'grad' => false, 'law' => false} }
  subject { MyAcademics::EnrollmentVerification.new(uid) }

  before do
    allow(HubEdos::MyAcademicStatus).to receive(:get_roles).and_return(roles)
  end

  context 'when providing feed' do
    context 'when message request succeeds' do
      it 'provides enrollment verification messages' do
        expect(feed[:messages]).to be
        expect(feed[:messages].count).to eq 3
        feed[:messages].each do |msg|
          expect(msg[:messageSetNbr]).to eq '32500'
        end
      end
    end

    context 'when message request error' do
      let(:error_response) { {:statusCode => '500'} }
      before { allow_any_instance_of(CampusSolutions::EnrollmentVerificationMessages).to receive(:get).and_return(error_response) }
      it 'provides error indicator' do
        expect(feed[:messages]).to be
        expect(feed[:messages][:errored]).to eq true
      end
    end

    it 'provides official enrollment verification link' do
      expect(feed[:requestUrl]).to be
      expect(feed[:requestUrl][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.SS_ENRL_VER_REQ.GBL'
      expect(feed[:requestUrl][:urlId]).to eq 'UC_CX_SS_ENRL_VER_REQ'
    end

    it 'provides academic roles' do
      expect(feed[:academicRoles]).to be
      expect(feed[:academicRoles]['ugrd']).to eq true
      expect(feed[:academicRoles]['law']).to eq false
    end
  end

end
