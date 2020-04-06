describe CampusSolutions::HasExamResults do
  let(:uid) { 61889 }
  let(:proxy) { described_class }
  let(:csid_with_test_history) { 1234 }
  let(:test_csid_no_data) { 19191919 }

  describe 'querying database view for has_exam_results' do

    context 'as a student with exam results data' do
      before do
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return csid_with_test_history
        allow(EdoOracle::Queries).to receive(:has_exam_results?).and_return(true)
      end
      subject { proxy.new(uid).get_feed }

      it 'should return true' do
        expect(subject[:hasExamResults]).to be_truthy
      end
    end

    context 'as a student without exam results data' do
      before { allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return test_csid_no_data }
      subject { proxy.new(uid).get_feed }

      it 'should return false' do
        expect(subject[:hasExamResults]).to be_falsey
      end
    end
  end

end
