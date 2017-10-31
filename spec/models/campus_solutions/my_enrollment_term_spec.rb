describe CampusSolutions::MyEnrollmentTerm do
  let(:user_id) { random_id }
  let(:term_id) { random_id }
  let(:api_response) do
    {
      feed: {
        enrollmentTerm: {
          studentId: "1234567",
          term: "2178"
        }
      }
    }
  end
  describe '.get_term' do
    context 'when feed is empty' do
      before { allow_any_instance_of(described_class).to receive(:get_feed).and_return(nil) }
      it 'returns nil' do
        result = described_class.get_term(user_id, term_id)
        expect(result).to eq nil
      end
    end
    context 'when feed is populated' do
      before { allow_any_instance_of(described_class).to receive(:get_feed).and_return(api_response) }
      it 'returns enrollment term object' do
        result = described_class.get_term(user_id, term_id)
        expect(result[:studentId]).to eq "1234567"
        expect(result[:term]).to eq "2178"
      end
    end
  end
end
