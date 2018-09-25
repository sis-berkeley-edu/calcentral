describe CampusSolutions::EmergencyPhoneController do

  let(:user_id) { '12345' }

  context 'updating emergency phone' do
    it 'should not let an unauthenticated user post' do
      post :post, {format: 'json', uid: '100'}
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = user_id
        User::Auth.stub(:where).and_return([User::Auth.new(uid: user_id, is_superuser: false, active: true)])
      end
      it 'should let an authenticated user post' do
        post :post,
             {
               bogus_field: 'abc',
               contactName: 'TEST',
               countryCode: '',
               phone: '805/658-4588',
               phoneType: 'CELL',
               extension: '123'
             }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']).to be
        expect(json['feed']['status']).to be
      end
    end
  end

  context 'deleting emergency phone' do
    it 'should not let an unauthenticated user delete' do
      delete :delete, {format: 'json', contactName: 'My Contact Name', phoneType: 'LOCL'}
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = user_id
        User::Auth.stub(:where).and_return([User::Auth.new(uid: user_id, is_superuser: false, active: true)])
      end
      it 'should let an authenticated user delete' do
        delete :delete,
             {
               bogus_field: 'abc',
               contactName: 'TEST',
               phoneType: 'LOCL'
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
