describe Financials::LoanHistory::MergedCumulative do

  let(:uid) { 61889 }
  let(:loan_history_active_cs_id) { 11667051 }
  let(:loan_history_inactive_cs_id) { 33889273 }

  describe 'making a call to the MergedCumulative API' do
    subject { described_class.new(uid).get_feed }

    context 'loan history inactive' do
      before do
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return loan_history_inactive_cs_id
      end

      it_behaves_like 'a proxy that returns all available, non user-specific data'

      it 'does not return any loan data' do
        expect(subject[:loans]).to be_falsey
      end
    end

    context 'loan history active' do
      before do
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return loan_history_active_cs_id
      end

      context 'it returns all expected data' do
        it_behaves_like 'a proxy that returns all available, non user-specific data'

        it 'returns loan data' do
          expect(subject[:loans]).to be_truthy
        end
      end
    end
  end
end
