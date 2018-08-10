describe Webcast::Rooms do

  let (:rooms_json_uri) { URI.parse "#{Settings.webcast_proxy.base_url}/warehouse/rooms.json" }

  context 'a fake proxy' do
    subject { Webcast::Rooms.new(fake: true) }

    context 'fake data' do
      it 'should return webcast-enabled rooms' do
        buildings = subject.get
        expect(buildings.length).to eq 26
        expect(buildings['ETCHEVERRY']).to contain_exactly('3106', '3107', '3108', '3109', '3111', '3113')
        expect(buildings['VALLEY LSB']).to contain_exactly('2040', '2050', '2060')
        expect(buildings['VLSB']).to be_nil
      end

      it 'should identify webcast-enabled room in list' do
        rooms = [
          {
            'building' => 'GIANNINI',
            'number' => '56'
          },
          {
            'building' => 'GPB',
            'number' => '100'
          },
          {
            'building' =>'SOUTH HALL',
            'number' => '390'
          }
        ]
        expect(subject.includes_any? rooms).to be true
      end

      it 'should find no webcast-enabled rooms in list' do
        rooms = [
          {
            'building' => 'GIANNINI',
            'number' => '56'
          },
          {
            'building' =>'SOUTH HALL',
            'number' => '390'
          }
        ]
        expect(subject.includes_any? rooms).to be false
      end
    end
  end
end
