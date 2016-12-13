describe CampusSolutions::CollegeSchedulerUrl do

  let(:options) { {user_id: '12349', term_id: '2168', acad_career: 'UGRD'} }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the enrollment card flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:scheduleplannerssolink][:url]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::CollegeSchedulerUrl.new options }
    subject { proxy.get }
    it_should_behave_like 'a proxy that gets data'
    it 'should get specific mock data' do
      expect(proxy.get_college_scheduler_url).to eq 'HTTPS://BERKELEYDEV.COLLEGESCHEDULER.COM/INDEX.ASPX?TICKET=C0EC99DE53574F78906FB21169B2045C_SSO'
    end

    context 'when advisor user id parameter present' do
      let(:advisor_user_id) { options[:user_id] }
      let(:student_user_id) { random_id }
      let(:student_campus_solutions_id) { random_id }
      let(:advisor_campus_solutions_id) { random_id }
      let(:stubbed_student_crosswalk_by_uid) { double(lookup_campus_solutions_id: student_campus_solutions_id) }
      let(:stubbed_advisor_crosswalk_by_uid) { double(lookup_campus_solutions_id: advisor_campus_solutions_id) }
      let(:expected_api_request_url) do
        proxy.settings.base_url + [
          "/UC_SR_COLLEGE_SCHDLR_URL.v1/get?",
          "EMPLID=#{student_campus_solutions_id}",
          "&STRM=#{options[:term_id]}",
          "&ACAD_CAREER=#{options[:acad_career]}",
          "&INSTITUTION=UCB01",
          "&ADVISORID=#{advisor_campus_solutions_id}"
        ].join('')
      end
      before do
        options.merge!(student_user_id: student_user_id)
        allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: student_user_id).and_return(stubbed_student_crosswalk_by_uid)
        allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: advisor_user_id).and_return(stubbed_advisor_crosswalk_by_uid)
      end
      it 'includes the advisor emplid in the CS API request' do
        expect(proxy).to receive(:get_response).with(expected_api_request_url, {:basic_auth=>{:username=>"secret", :password=>"secret"}}).and_call_original
        proxy.get
      end
    end
  end

end
