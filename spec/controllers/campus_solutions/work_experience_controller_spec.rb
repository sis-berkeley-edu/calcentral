describe CampusSolutions::WorkExperienceController do

  let(:user_id) { '12351' }

  context 'updating work experience' do
    it 'should not let an unauthenticated user post' do
      post :post, params: { format: 'json', uid: '100' }
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = user_id
        User::Auth.stub(:where).and_return([User::Auth.new(uid: user_id, is_superuser: false, active: true)])
      end
      it 'should let an authenticated user post' do
        post :post, params: {
          bogus_field: 'abc',
          sequenceNbr: '',
          employmentDescr: 'In N Out Burger',
          country: 'USA',
          city: 'Oakland',
          state: 'CA',
          phone: '5102450987',
          startDt: '01/15/2012',
          endDt: '02/20/2015',
          titleLong: 'Burger Flipper',
          employFrac: '50',
          hoursPerWeek: '4',
          endingPayRate: '10000',
          currencyType: 'USD',
          payFrequency: 'M'
        }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']).to be
        expect(json['feed']['status']).to be
      end
    end
  end
end
