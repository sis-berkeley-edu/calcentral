describe CampusSolutions::MyEnrollmentTerms do
  let(:user_id) { random_id }
  let(:api_response) do
    {
      feed: {
        enrollmentTerms: [
          { termId: '2178' },
          { termId: '2168' },
          { termId: '2172' },
        ]
      }
    }
  end
  describe '.get_terms' do
    context 'when feed is empty' do
      before { allow_any_instance_of(described_class).to receive(:get_feed).and_return(nil) }
      it 'returns nil' do
        result = described_class.get_terms(user_id)
        expect(result).to eq nil
      end
    end
    context 'when feed is populated' do
      before { allow_any_instance_of(described_class).to receive(:get_feed).and_return(api_response) }
      it 'returns sorts list of term objects' do
        result = described_class.get_terms(user_id)
        expect(result[0][:termId]).to eq '2168'
        expect(result[1][:termId]).to eq '2172'
        expect(result[2][:termId]).to eq '2178'
      end
    end
  end
end
