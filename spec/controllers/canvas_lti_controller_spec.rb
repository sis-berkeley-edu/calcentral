describe CanvasLtiController do

  let(:lti_values) {{
    'canvas_user_login_id' => random_id,
    'canvas_user_id' => random_id,
    'canvas_course_id' => random_id,
    'canvas_masquerading_user_id' => canvas_masquerading_user_id
  }}
  let(:lti) do
    allow(obj = double).to receive(:get_custom_param) { |key| lti_values[key] }
    obj
  end
  let(:canvas_masquerading_user_id) { CanvasLtiController::EMPTY_MASQUERADE_VALUE }

  shared_examples 'an LTI authentication' do
    it 'embeds all session variables' do
      subject.send(:authenticate_by_lti, lti)
      expect(session['user_id']).to eq lti_values['canvas_user_login_id']
      expect(session['canvas_user_id']).to eq lti_values['canvas_user_id']
      expect(session['canvas_course_id']).to eq lti_values['canvas_course_id']
    end
  end

  shared_examples 'an LTI authentication checking for masquerade' do
    context 'when the LTI user is masquerading' do
      let(:canvas_masquerading_user_id) { random_id }
      it 'notes that the authentication is valid only for LTI' do
        subject.send(:authenticate_by_lti, lti)
        expect(session['canvas_masquerading_user_id']).to eq canvas_masquerading_user_id
        expect(session['lti_authenticated_only']).to be true
      end
      it 'does not initiate a view-as session' do
        subject.send(:authenticate_by_lti, lti)
        expect(session).not_to include SessionKey.original_user_id
      end
    end
    context 'when the LTI user is not masquerading' do
      it 'does not flag the authentication' do
        subject.send(:authenticate_by_lti, lti)
        expect(session).not_to include 'canvas_masquerading_user_id'
        expect(session['lti_authenticated_only']).to be_falsey
      end
    end
  end

  describe 'advisor-view-as restriction' do
    before do
      allow(Settings.features).to receive(:reauthentication).and_return false
    end
    context 'when the user is logged into CalCentral' do
      let(:make_request) {
        session['user_id'] = lti_values['canvas_user_login_id']
        subject.send(:authenticate_by_lti, lti)
        get action
      }
      context 'site creation' do
        let(:action) { :lti_site_creation }
        it_behaves_like 'an unauthorized endpoint for users in advisor-view-as mode'
      end
      context 'manage sections' do
        let(:action) { :lti_course_manage_official_sections }
        it_behaves_like 'an unauthorized endpoint for users in advisor-view-as mode'
      end
    end
  end

  describe 'authenticate_by_lti' do
    context 'when the user is not logged into CalCentral' do
      it_behaves_like 'an LTI authentication'
      it_behaves_like 'an LTI authentication checking for masquerade'
    end
    context 'when the user is already logged into CalCentral' do
      before do
        session['user_id'] = lti_values['canvas_user_login_id']
      end
      it_behaves_like 'an LTI authentication'
      it 'does not flag the authentication' do
        expect(session['lti_authenticated_only']).to be_falsey
      end
    end
    context 'when the user does not match an existing CalCentral login' do
      before do
        session['user_id'] = random_id
      end
      it_behaves_like 'an LTI authentication'
      it_behaves_like 'an LTI authentication checking for masquerade'
      it 'wipes the session first' do
        session['some_random_junk'] = random_id
        subject.send(:authenticate_by_lti, lti)
        expect(session['some_random_junk']).to be_nil
      end
    end
  end

  describe '#embedded' do
    before do
      session['user_id'] = random_id
      session['lti_authenticated_only'] = true
      allow_any_instance_of(CanvasLti::Lti).to receive(:validate_tool_provider).and_return(lti)
    end
    it 'switches to the new authentication' do
      post :embedded, url: 'something'
      assert_response :success
      expect(session['user_id']).to eq lti_values['canvas_user_login_id']
      expect(session['canvas_user_id']).to eq lti_values['canvas_user_id']
      expect(session['canvas_course_id']).to eq lti_values['canvas_course_id']
    end
  end

end
