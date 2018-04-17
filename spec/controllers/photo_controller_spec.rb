describe PhotoController do

  let(:uid) { random_id }

  shared_examples 'a controller with no photo' do
    it 'returns an empty body' do
      make_request
      expect(response.status).to eq 200
      expect(response.body).to eq ''
    end
  end

  shared_examples 'a controller with a photo' do
    it 'renders raw image' do
      make_request
      expect(response.status).to eq 200
      expect(response.body).to eq 'photo_binary_content'
    end
  end

  shared_examples 'a controller that prevents unauthorized access' do
    it 'returns an empty body and an error status' do
      make_request
      expect(response.status).to eq 403
      expect(response.body).to eq ''
    end
  end

  shared_examples 'an endpoint that returns a response' do
    it_should_behave_like 'an authenticated endpoint'

    context 'when a user is authenticated' do
      before do
        session['user_id'] = uid
        allow_any_instance_of(Cal1card::Photo).to receive(:get_feed).and_return(test_photo_object)
      end

      context 'when person has no photo' do
        let(:test_photo_object) { {} }
        it_should_behave_like 'a controller with no photo'
      end

      context 'when person has photo' do
        let(:test_photo_object) { {photo: 'photo_binary_content'} }
        it_should_behave_like 'a controller with a photo'

        context 'delegate view' do
          before do
            session[SessionKey.original_delegate_user_id] = uid
            allow(Settings.features).to receive(:cs_delegated_access).and_return true
          end
          it_should_behave_like 'a controller that prevents unauthorized access'
        end
      end
    end
  end

  describe '#my_photo' do
    let(:make_request) { get :my_photo }
    it_should_behave_like 'an endpoint that returns a response'
  end

  describe '#photo' do
    let(:make_request) { get :photo, uid: random_id }
    let(:user_attributes) {
      {
        roles: {
          concurrentEnrollmentStudent: true,
          exStudent: true,
          expiredAccount: false,
          faculty: true,
          guest: false,
          registered: true,
          staff: true,
          student: true,
          undergrad: true,
          advisor: is_advisor
        }
      }
    }

    before do
      session['user_id'] = uid
      allow(User::AggregatedAttributes).to receive(:new).and_return double get_feed: user_attributes
      allow_any_instance_of(User::Auth).to receive(:active).and_return true
      allow_any_instance_of(User::Auth).to receive(:is_superuser?).and_return is_super_user
    end

    context 'when user is an advisor' do
      let(:is_advisor) { true }
      let(:is_super_user) { false }
      it_should_behave_like 'an endpoint that returns a response'
    end

    context 'when user is a superuser' do
      let(:is_advisor) { false }
      let(:is_super_user) { true }
      it_should_behave_like 'an endpoint that returns a response'
    end

    context 'when user is not authorized to see another user\'s photo' do
      let(:is_advisor) { false }
      let(:is_super_user) { false }
      let(:test_photo_object) { {photo: 'photo_binary_content'} }
      it_should_behave_like 'a controller that prevents unauthorized access'
    end

  end

end
