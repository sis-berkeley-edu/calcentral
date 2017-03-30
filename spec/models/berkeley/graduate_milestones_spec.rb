describe Berkeley::GraduateMilestones do

  describe '#get_status' do

    shared_examples 'a translator that gracefully handles invalid values' do
      context 'when status_code is nil' do
        let(:status_code) { nil }
        it 'returns nil' do
          expect(subject).to eq nil
        end
      end
      context 'when status_code is garbage' do
        let(:status_code) { 'GOATYOGA' }
        it 'returns nil' do
          expect(subject).to eq nil
        end
      end
    end

    shared_examples 'a translator for generic statuses' do
      context 'when status_code is N' do
        let(:status_code) { 'N' }
        it 'returns Not Satisfied' do
          expect(subject).to eq 'Not Satisfied'
        end
      end
      context 'when status_code is Y' do
        let(:status_code) { 'Y' }
        it 'returns Completed' do
          expect(subject).to eq 'Completed'
        end
      end
    end

    shared_examples 'a translator for statuses specific to Qualifying Approval' do
      context 'when status_code is N' do
        let(:status_code) { 'N' }
        it 'returns Not Satisfied' do
          expect(subject).to eq 'Not Satisfied'
        end
      end
      context 'when status_code is Y' do
        let(:status_code) { 'Y' }
        it 'returns Approved' do
          expect(subject).to eq 'Approved'
        end
      end
    end

    shared_examples 'a translator for statuses specific to Qualifying Results' do
      context 'when status_code is P' do
        let(:status_code) { 'P' }
        it 'returns Passed' do
          expect(subject).to eq 'Passed'
        end
      end
      context 'when status_code is F' do
        let(:status_code) { 'F' }
        it 'returns Failed' do
          expect(subject).to eq 'Failed'
        end
      end
      context 'when status_code is PF' do
        let(:status_code) { 'PF' }
        it 'returns Partially Failed' do
          expect(subject).to eq 'Partially Failed'
        end
      end
    end

    context 'when milestone_code is not provided' do
      subject { described_class.get_status(status_code) }

      it_behaves_like 'a translator that gracefully handles invalid values'
      it_behaves_like 'a translator for generic statuses'
    end

    context 'when milestone_code is provided' do
      subject { described_class.get_status(status_code, milestone_code) }

      context 'when milestone_code is garbage' do
        let(:milestone_code) { 'CATCAFE'}

        it_behaves_like 'a translator that gracefully handles invalid values'
        it_behaves_like 'a translator for generic statuses'
      end

      context 'when milestone_code is valid but not special' do
        let(:milestone_code) { 'AAGADVMAS1'}

        it_behaves_like 'a translator that gracefully handles invalid values'
        it_behaves_like 'a translator for generic statuses'
      end

      context 'when milestone_code is special (Qualifying Approval)' do
        let(:milestone_code) { 'AAGQEAPRV'}

        it_behaves_like 'a translator that gracefully handles invalid values'
        it_behaves_like 'a translator for statuses specific to Qualifying Approval'
      end

      context 'when milestone_code is special (Qualifying Results)' do
        let(:milestone_code) { 'AAGQERESLT'}

        it_behaves_like 'a translator that gracefully handles invalid values'
        it_behaves_like 'a translator for statuses specific to Qualifying Results'
      end
    end

  end
end
