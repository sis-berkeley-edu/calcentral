describe MyCampusLinksController do

  it_should_behave_like 'a user authenticated api endpoint' do
    let(:make_request) { get :get_feed }
  end

  describe '#refresh' do
    before do
      allow(Settings.features).to receive(:campus_links_from_file).and_return(campus_links_from_file)
      allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_author?).and_return is_user_authorized
      # allow(Links::CampusLinkLoader).to receive(:delete_links!)
      # allow(Links::CampusLinkLoader).to receive(:load_links!)
    end

    context 'when the campus_links_from_file feature flag is on' do
      let(:campus_links_from_file) { true }
      let(:is_user_authorized) { true }

      it 'should not load the links into Postgres' do
        session['user_id'] = random_id
        expect(Links::CampusLinkLoader).not_to receive(:delete_links!)
        expect(Links::CampusLinkLoader).not_to receive(:load_links!)
        get :refresh
      end
    end
    context 'when the campus_links_from_file feature flag is off' do
      let(:campus_links_from_file) { false }
      let(:is_user_authorized) { true }

      it 'should load the links into Postgres' do
        session['user_id'] = random_id
        expect(Links::CampusLinkLoader).to receive(:delete_links!)
        expect(Links::CampusLinkLoader).to receive(:load_links!)
        get :refresh
      end
    end
  end
end
