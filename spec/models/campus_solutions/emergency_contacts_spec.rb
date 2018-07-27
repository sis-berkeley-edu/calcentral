describe CampusSolutions::EmergencyContacts do

  let(:user_id) {'1024600'}

  shared_examples 'a proxy that gets data' do
    let(:proxy) { CampusSolutions::EmergencyContacts.new(fake: true, user_id: user_id) }
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the emergency contact feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do

      students_feed = subject[:feed][:students]
      if students_feed && students_feed[:student][:emergencyContacts]
        emergency_contacts = students_feed[:student][:emergencyContacts][:emergencyContact]
        expect(emergency_contacts.length).to be

        # primary contact always at head position
        primary = emergency_contacts[0]
        expect(primary[:primaryContact]).to eq "Y"
        if primary[:emergencyPhones].length > 0
          expect(primary[:emergencyPhones][0][:primaryPhone]).to eq "Y"
        end

        # subsequent contacts
        i = 1
        while i < emergency_contacts.length
          contact = emergency_contacts[i]
          i += 1
          expect(contact[:primaryContact]).to eq "N"
          if contact[:emergencyPhones].length > 0
            expect(contact[:emergencyPhones][0][:primaryPhone]).to eq "N"
          end
        end
      end
    end
  end

  context 'mock proxy' do
    let(:fake_proxy) { true }
    before do
      allow_any_instance_of(CampusSolutions::EmergencyContacts).to receive(:xml_filename).and_return filename
    end

    context 'empty contacts' do
      let(:filename) { 'emergency_contacts_empty.xml'}
      it_should_behave_like 'a proxy that gets data'
    end

    context 'single contact' do
      let(:filename) { 'emergency_contacts_single.xml'}
      it_should_behave_like 'a proxy that gets data'
    end

    context 'multiple contacts' do
      let(:filename) { 'emergency_contacts.xml'}
      it_should_behave_like 'a proxy that gets data'
    end
  end
end
