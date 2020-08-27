describe HubEdos::PersonApi::V1::Names do
  let(:identifiers_data) do
    [
      {
        'type': {
          'code' => 'PRF',
          'description' => 'Preferred'
        },
        'familyName' => 'Scarn',
        'givenName' => 'Michael',
        'formattedName' => 'Michael Scarn',
        'preferred': true,
        'disclose': false,
        'uiControl': {
          'code' => 'U',
          'description' => 'Edit - No Delete'
        },
        'fromDate': '2018-05-04'
      },
      {
        'type': {
          'code' => 'PRI',
          'description' => 'Primary'
        },
        'familyName' => 'Scott',
        'givenName' => 'Michael',
        'formattedName' => 'Michael Scott',
        'preferred': false,
        'disclose': false,
        'uiControl': {
          'code' => 'D',
          'description' => 'Display Only'
        },
        'fromDate': '2017-04-14'
      }
    ]
  end
  subject { described_class.new(identifiers_data) }

  describe '#all' do
    its('all.count') { should eq(2) }
    it 'should return only idenfifier objects' do
      subject.all.each do |identifier|
        expect(identifier).to be_an_instance_of HubEdos::PersonApi::V1::Name
      end
    end
  end

end
