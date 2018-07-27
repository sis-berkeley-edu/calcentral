describe CampusSolutions::WorkExperience do
  let(:user_id) { '12351' }

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::WorkExperience.new(fake: true, user_id: user_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        titleLong: 'Karate Instructor'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 14
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:titleLong]).to eq 'Karate Instructor'
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        hoursPerWeek: '40'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['Prior_Work_Exp']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['HOURS_PER_WEEK']).to eq '40'
      end
    end

    context 'performing a post' do
      let(:params) { {
        employmentDescr: 'Millionaire',
        country: 'USA'
      } }
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that properly observes the profile feature flag'
      it_behaves_like 'a proxy that got data successfully'
    end
  end
end
