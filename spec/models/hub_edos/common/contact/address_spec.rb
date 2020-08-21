describe HubEdos::Common::Contact::Address do
  let(:attributes) do
    {
      'type' => {
        'code' => 'HOME',
        'description' => 'Home'
      },
      'address1' => '3221 Walton Road',
      'city' => 'Berkeley',
      'stateCode' => 'CA',
      'stateName' => 'California',
      'postalCode' => '94704',
      'countryCode' => 'USA',
      'countryName' => 'United States',
      'formattedAddress' => "3221 Walton Road\nBerkeley, California 94704",
      'disclose' => true,
      'uiControl' => {
        'code' => 'U',
        'description' => 'Edit - No Delete'
      },
      'fromDate' => '2019-03-15'
    }
  end
  subject { described_class.new(attributes) }
  its(:type) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:address_1) { should eq '3221 Walton Road' }
  its(:address_2) { should eq nil }
  its(:address_3) { should eq nil }
  its(:address_4) { should eq nil }
  its(:num_1) { should eq nil }
  its(:num_2) { should eq nil }
  its(:addr_field_1) { should eq nil }
  its(:addr_field_2) { should eq nil }
  its(:addr_field_3) { should eq nil }
  its(:house_type) { should eq nil }
  its(:city) { should eq 'Berkeley' }
  its(:county) { should eq nil }
  its(:state_code) { should eq 'CA' }
  its(:state_name) { should eq 'California' }
  its(:postal_code) { should eq '94704' }
  its(:country_code) { should eq 'USA' }
  its(:country_name) { should eq 'United States' }
  its(:formatted_address) { should eq "3221 Walton Road\nBerkeley, California 94704" }
  its(:primary) { should eq nil }
  its(:disclose) { should eq true }
  its(:ui_control) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:last_changed_by) { should eq nil }
  its(:from_date) { should eq Date.parse('2019-03-15') }
  its(:to_date) { should eq nil }
end
