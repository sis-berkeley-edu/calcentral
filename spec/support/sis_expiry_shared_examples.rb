shared_context 'when uid lookup is successful' do
  before do
    allow_any_instance_of(CalnetCrosswalk::ByCsId).to receive(:lookup_ldap_uid).and_return uid
  end
  let(:uid) { '123' }
end

shared_context 'when uid lookup is unsuccessful' do
  before do
    allow_any_instance_of(CalnetCrosswalk::ByCsId).to receive(:lookup_ldap_uid).and_return nil
  end
end

shared_examples 'a provider receiving a malformed response' do
  it 'logs an error' do
    expect(CalnetCrosswalk::ByCsId).not_to receive(:lookup_ldap_uid)
    expect(Rails.logger).to receive(:error).with /Could not parse Campus Solutions ID from event/
    subject.get_uids(event)
  end
end

shared_examples 'a provider receiving an empty response' do
  it 'logs an error' do
    expect(CalnetCrosswalk::ByCsId).not_to receive(:lookup_ldap_uid)
    expect(Rails.logger).to receive(:error).with /No UID found for Campus Solutions ID/
    subject.get_uids(event)
  end
end
