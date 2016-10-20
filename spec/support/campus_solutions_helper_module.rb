module CampusSolutionsHelperModule

  shared_examples 'a simple proxy that returns errors' do
    before {
      proxy.set_response(status: 506, body: '')
    }
    it 'returns errors properly' do
      expect(subject[:errored]).to eq true
      expect(subject[:statusCode]).to eq 503
    end
  end

  shared_examples 'an unauthenticated user' do
    it 'returns 401' do
      get feed
      expect(response.status).to eq 401
      expect(response.body.strip).to eq ''
    end
  end

  shared_examples 'a proxy that got data successfully' do
    it 'has a 200 statusCode and a non-null feed' do
      expect(subject[:statusCode]).to eq(200), "expected 200, got #{subject.inspect}"
      expect(subject[:feed]).to be, "expected a feed, got #{subject.inspect}"
    end
  end

  shared_examples 'a successful feed' do
    it 'has some data' do
      session['user_id'] = user_id
      get feed
      json = JSON.parse(response.body)
      expect(json['statusCode']).to eq 200
      expect(json['feed'][feed_key]).to be
    end
  end

  shared_examples 'a successful feed during view-as session' do
    before {
      allow(Settings.features).to receive(:reauthentication).and_return false
    }
    it 'should exclude certain student data from the feed' do
      session['user_id'] = user_id
      session[view_as_key] = random_id
      get feed
      json = JSON.parse response.body
      expect(json['statusCode']).to eq 200
      feed = json['feed'][feed_key]
      expect(feed).to have(expected_elements.length).items
      expect(feed).to include *expected_elements
    end
  end

  shared_examples 'a proxy that responds to user error gracefully' do
    it 'returns the right status code and helpful error message' do
      expect(subject[:statusCode]).to eq 400
      expect(subject[:errored]).to eq true
      expect(subject[:feed][:errmsgtext]).to be
    end
  end

  shared_examples 'a proxy that observes a feature flag' do
    before do
      allow(Settings.features).to receive(flag).and_return(false)
    end
    it 'should return an empty feed if the feature is off' do
      expect(subject).to be_empty
    end
  end

  shared_examples 'a proxy that properly observes the profile feature flag' do
    let(:flag) { :cs_profile }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the SIR feature flag' do
    let(:flag) { :cs_sir }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the finaid feature flag' do
    let(:flag) { :cs_fin_aid }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the finaid award compare feature flag' do
    let(:flag) { :cs_fin_aid_award_compare }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the holds feature flag' do
    let(:flag) { :cs_holds }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the delegated access feature flag' do
    let(:flag) { :cs_delegated_access }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the enrollment card flag' do
    let(:flag) { :cs_enrollment_card }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the billing feature flag' do
    let(:flag) { :cs_billing }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the emergency contact feature flag' do
    let(:flag) { :cs_profile_emergency_contacts }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the student success feature flag' do
    let(:flag) { :advising_student_success }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the graduate degree progress for advisor feature flag' do
    let(:flag) { :cs_degree_progress_grad_advising }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the graduate degree progress for student feature flag' do
    let(:flag) { :cs_degree_progress_grad_student }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the committees feature flag' do
    let(:flag) { :cs_committees }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the undergrad degree progress for student feature flag' do
    let(:flag) { :cs_degree_progress_ugrd_advising }
    it_behaves_like 'a proxy that observes a feature flag'
  end
end
