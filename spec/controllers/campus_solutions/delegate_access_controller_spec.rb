describe CampusSolutions::DelegateAccessController do
  let(:user_id) { '12346' }

  context 'user not authenticated' do
    it 'should not get students' do
      get :get_students,  params: { format: 'json', uid: '100' }
      expect(response.status).to eq 401
    end

    it 'should not permit post' do
      post :post, params: { format: 'json', uid: '100' }
      expect(response.status).to eq 401
    end
  end
  context 'authenticated user' do
    before do
      session['user_id'] = user_id
      allow(User::Auth).to receive(:where).and_return [User::Auth.new(uid: user_id, is_superuser: false, active: true)]
    end
    context 'post' do
      before do
        expect(CampusSolutions::DelegateStudentsExpiry).to receive(:expire).once.with user_id
        expect(User::Api).to receive(:expire).once.with user_id
      end
      it 'should link a claimed student' do
        post :post, params: {
          proxyEmailAddress: 'squire.allworthy@gmail.com',
          securityKey: 'uy786XD'
        }
        expect(response.status).to eq 200
        json = JSON.parse response.body
        expect(json['statusCode']).to eq 200
        expect(json['feed']['status']).to be_present
      end
    end
    context 'get' do
      before do
        expect(CampusSolutions::DelegateStudentsExpiry).to receive(:expire).never
        expect(User::Api).to receive(:expire).never
      end
      it 'should get students list' do
        get :get_students
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']['students']).to be_present
        json['feed']['students'].each do |student|
          expect(student['campusSolutionsId']).to be_present
          expect(student['fullName']).to be_present
          expect(student['privileges']).to be_present
        end
      end

      it 'should get terms and conditions' do
        get :get_terms_and_conditions
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']['termsAndConditions']).to include 'Excepteur sint occaecat'
      end

      it 'should get Campus Solutions URL for managing delegates' do
        get :get_delegate_management_url
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']['delegatedAccessUrl']['url']).to eq 'https://bcs-web-dev-03.is.berkeley.edu:8443/psc/bcsdev/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.SS_CC_DA_SHAREINFO.GBL?Page=SS_CC_DA_HDR&Action=A&ForceSearch=Y&TargetFrameName=None'
      end
    end
  end
end
