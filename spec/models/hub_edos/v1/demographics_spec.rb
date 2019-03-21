describe HubEdos::V1::Demographics do

  context 'mock proxy' do
    let(:include_fields) { nil }
    let(:proxy) { HubEdos::V1::Demographics.new(fake: true, user_id: '61889', include_fields: include_fields) }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['ethnicities'][0]['group']['code']).to eq '2'
      expect(subject[:feed]['student']['usaCountry']).to be
      expect(subject[:feed]['student']['residency']['official']).to be
    end

    it 'should return default fields only' do
      fields = subject[:feed]['student']
      %w(ethnicities usaCountry residency).each do |key|
        expect(fields[key]).to be_present
      end
      expect(fields['identifiers']).to be_blank
    end

    context 'view-as session' do
      let(:include_fields) { ['residency'] }
      it 'should return only the specified fields through the public endpoint' do
        fields = subject[:feed]['student']
        %w(ethnicities usaCountry).each do |key|
          expect(fields[key]).to be_blank
        end
        expect(fields['residency']).to be_present
      end
      describe '#get_internal' do
        it 'keeps the uncensored feed available for caching' do
          fields = proxy.get_internal[:feed]['student']
          %w(ethnicities usaCountry residency).each do |key|
            expect(fields[key]).to be_present
          end
          expect(fields['identifiers']).to be_blank
        end
      end
    end
  end
end
