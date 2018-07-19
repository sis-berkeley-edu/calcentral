describe Financials::LoanHistory::MergedAidYears do

  let(:uid) { 61889 }
  let(:loan_history_active_cs_id) { 11667051 }
  let(:not_enrolled_pre_2168_cs_id) { 22778162 }
  let(:loan_history_inactive_cs_id) { 33889273 }

  describe 'making a call to the MergedAidYears API' do
    subject { described_class.new(uid).get_feed }

    context 'loan history inactive' do
      before { allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return loan_history_inactive_cs_id }

      it_behaves_like 'a proxy that returns all available, non user-specific data'

      it 'does not return any loan data' do
        expect(subject[:loans]).to be_falsey
      end
    end

    context 'loan history active' do
      before { allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return loan_history_active_cs_id }

      context 'it returns all expected data' do
        it_behaves_like 'a proxy that returns all available, non user-specific data'

        it 'returns loan data' do
          expect(subject[:aidYears]).to have(2).items
          expect(subject[:aidYears][0][:loans]).to have(8).items
          expect(subject[:aidYears][1][:loans]).to have(9).items
        end
      end

      context 'messaging for students enrolled prior to Fall 2016' do

        context 'when the student was enrolled prior to Fall 2016' do
          it 'includes the message' do
            expect(subject[:messaging]).to include :enrolledPriorToFall2016
            expect(subject[:messaging][:enrolledPriorToFall2016][:description]).to be_truthy
          end
        end

        context 'when the student was not enrolled prior to Fall 2016' do
          before { allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return not_enrolled_pre_2168_cs_id }
          it 'does not include the message' do
            expect(subject[:messaging]).not_to include :enrolledPriorToFall2016
          end
        end

      end
    end
  end
end
