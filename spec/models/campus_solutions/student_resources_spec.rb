describe CampusSolutions::StudentResources do
  let(:uid) { '61889' }
  let(:fake_proxy) { true }
  let(:proxy) { CampusSolutions::StudentResources.new({ user_id: uid, fake: fake_proxy }) }
  let(:roles) do
    {
      advisor: false,
      applicant: false,
      concurrentEnrollmentStudent: false,
      confidential: false,
      expiredAccount: false,
      exStudent: false,
      faculty: false,
      graduate: false,
      guest: false,
      law: false,
      registered: false,
      releasedAdmit: false,
      staff: false,
      student: false,
      undergrad: false
    }
  end
  let(:current_academic_roles) do
    {
      "doctorScienceLaw" => false,
      "fpf" => false,
      "haasBusinessAdminMasters" => false,
      "haasBusinessAdminPhD" => false,
      "haasFullTimeMba" => false,
      "haasEveningWeekendMba" => false,
      "haasExecMba" => false,
      "haasMastersFinEng" => false,
      "haasMbaPublicHealth" => false,
      "haasMbaJurisDoctor" => false,
      "jurisSocialPolicyMasters" => false,
      "jurisSocialPolicyPhC" => false,
      "jurisSocialPolicyPhD" => false,
      "ugrdUrbanStudies" => false,
      "summerVisitor" => false,
      "courseworkOnly" => false,
      "lawJspJsd" => false,
      "lawJdLlm" => false,
      "masterOfLawsLlm" => false,
      "lawVisiting" => false,
      "lawJdCdp" => false,
      "ugrd" => false,
      "grad" => false,
      "law" => false,
      "concurrent" => false,
      "lettersAndScience" => false,
      "degreeSeeking" => false,
      "ugrdNonDegree" => false
    }
  end
  let(:historical_academic_roles) do
    {
      "summerVisitor" => false,
      "degreeSeeking" => false
    }
  end
  let(:link_response) do
    {
      url: 'some url'
    }
  end
  before do
    allow_any_instance_of(CampusSolutions::StudentResources).to receive(:lookup_campus_solutions_id).and_return('12345')
    allow_any_instance_of(User::AggregatedAttributes).to receive(:get_feed).and_return({roles: roles})
    allow_any_instance_of(MyAcademics::MyAcademicRoles).to receive(:get_feed).and_return({current: current_academic_roles, historical: historical_academic_roles})
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).and_return(link_response)
  end
  subject { proxy.get }


  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:resources]).not_to be_empty
  end

  context 'as a general undergraduate student' do
    before { roles.merge!({ student: true, undergrad: true }) }
    it 'returns the expected number of sections/links' do
      expect(subject[:feed][:resources]).to have(4).items
      expect(subject[:feed][:resources][0][:links]).to have(4).items
      expect(subject[:feed][:resources][1][:links]).to have(3).items
      expect(subject[:feed][:resources][2][:links]).to have(2).items
      expect(subject[:feed][:resources][3][:links]).to have(2).items
    end
  end

  context 'as a graduate student' do
    before { roles.merge!({ student: true, graduate: true }) }
    it 'returns the expected number of sections/links' do
      expect(subject[:feed][:resources]).to have(4).items
      expect(subject[:feed][:resources][0][:links]).to have(10).items
      expect(subject[:feed][:resources][1][:links]).to have(3).items
      expect(subject[:feed][:resources][2][:links]).to have(2).items
      expect(subject[:feed][:resources][3][:links]).to have(2).items
    end
  end

  context 'as a ucbx-only student' do
    before { roles.merge!({concurrentEnrollmentStudent: true}) }
    it 'returns the expected number of sections/links' do
      expect(subject[:feed][:resources]).to have(2).items
      expect(subject[:feed][:resources][0][:links]).to have(1).items
      expect(subject[:feed][:resources][1][:links]).to have(2).items
    end
  end

  context 'as a visiting law student' do
    before do
      current_academic_roles.merge!({"lawVisiting" => true})
      roles.merge!({student: true, law: true})
    end
    it 'returns the expected number of sections/links' do
      expect(subject[:feed][:resources]).to have(4).items
      expect(subject[:feed][:resources][0][:links]).to have(5).items
      expect(subject[:feed][:resources][1][:links]).to have(1).items
      expect(subject[:feed][:resources][2][:links]).to have(2).items
      expect(subject[:feed][:resources][3][:links]).to have(2).items
    end
  end

  context 'as a non-degree seeking summer visitor' do
    before do
      historical_academic_roles.merge!({"summerVisitor" => true})
      roles.merge!({student: true, undergrad: true})
    end
    it 'returns the expected number of sections/links' do
      expect(subject[:feed][:resources]).to have(4).items
      expect(subject[:feed][:resources][0][:links]).to have(2).items
      expect(subject[:feed][:resources][1][:links]).to have(2).items
      expect(subject[:feed][:resources][2][:links]).to have(2).items
      expect(subject[:feed][:resources][3][:links]).to have(2).items
    end
  end
end
