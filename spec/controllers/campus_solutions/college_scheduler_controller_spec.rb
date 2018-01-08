describe CampusSolutions::CollegeSchedulerController do
  let(:options) { {term_id: '2167', acad_career: 'UGRD'} }
  let(:scheduler_url) { 'HTTPS://BERKELEYDEV.COLLEGESCHEDULER.COM/INDEX.ASPX?TICKET=C0EC99DE53574F78906FB21169B2045C_SSO' }

  context 'no authenticated user' do
    it 'returns 401' do
      get :get, options
      expect(response.status).to eq 401
      expect(response.body.strip).to eq ''
    end
  end

  context 'authenticated user' do
    let(:user_id) { '12349' }
    before { session['user_id'] = user_id }

    context 'feature flag off' do
      before { allow(Settings.features).to receive(:cs_enrollment_card).and_return false }
      it 'should redirect to 404' do
        get :get, options
        expect(response).to redirect_to '/404'
      end
    end

    context 'feature flag on' do
      before { allow(Settings.features).to receive(:cs_enrollment_card).and_return true }
      it 'should redirect to a College Scheduler URL' do
        get :get, options
        expect(response).to redirect_to scheduler_url
      end

      context 'when including student user id' do
        let(:student_user_id) { random_id }
        let(:mock_proxy) { double(get_college_scheduler_url: scheduler_url)}
        let(:advisor_search_result) { {ldapUid: user_id, campusSolutionsId: "54321", roles: {advisor: true}} }
        let(:mock_user_search_by_uid) { double(search_users_by_uid: advisor_search_result) }
        let(:expected_options) { options.merge!({user_id: user_id}) }
        before { options.merge!({student_user_id: student_user_id}) }

        context 'when user is an advisor' do
          before { allow(User::SearchUsersByUid).to receive(:new).with(id: user_id, roles: [:advisor]).and_return(mock_user_search_by_uid) }
          it 'should initialize proxy with student user id present' do
            expect(CampusSolutions::CollegeSchedulerUrl).to receive(:new).with(expected_options).and_return(mock_proxy)
            get :get_advisor, options
          end

          it 'should redirect to a College Scheduler URL' do
            get :get_advisor, options
            expect(response).to redirect_to scheduler_url
          end
        end

        context 'when user is not an advisor' do
          before { allow(User::SearchUsersByUid).to receive(:new).with(id: user_id, roles: [:advisor]).and_raise(Pundit::NotAuthorizedError, "User (UID: #{user_id}) is not an Advisor") }
          it 'should redirect to 404' do
            get :get_advisor, options
            expect(response.status).to_not eq(302)
            expect(response.status).to eq(403)
            expect(response.body).to eq ''
          end
        end
      end

      context 'when College Scheduler URL not found' do
        before { allow_any_instance_of(CampusSolutions::CollegeSchedulerUrl).to receive(:get_college_scheduler_url).and_return(nil) }
        it 'should redirect to 404' do
          get :get, options
          expect(response).to redirect_to '/404'
        end
      end
    end
  end
end
