describe Notifications::SisExpiryStudentsProvider do

  describe '#get_uids' do
    subject { described_class.new }

    context 'when given nil' do
      let(:event) { nil }
      it_behaves_like 'a provider receiving a malformed response'
    end

    context 'when given an empty event' do
      let(:event) { {} }
      it_behaves_like 'a provider receiving a malformed response'
    end

    context 'when given an empty payload' do
      let(:event) do
        {
          'payload' => {}
        }
      end
      it_behaves_like 'a provider receiving a malformed response'
    end

    context 'when payload' do
      let(:event) do
        {
          'payload' => {
            'students' => students
          }
        }
      end

      context 'is missing the \'id\' node' do
        let(:students) { {} }
        it_behaves_like 'a provider receiving a malformed response'
      end

      context 'contains an empty array' do
        let(:students) { {'id' => []} }
        it 'returns an empty array' do
          uids = subject.get_uids(event)
          expect(uids).to eq([])
        end
      end

      context 'contains a single ID' do
        include_context 'when uid lookup is unsuccessful'
        let(:students) { {'id' => '61889'} }
        it_behaves_like 'a provider receiving an empty response'
      end

      context 'when given an array of IDs' do
        include_context 'when uid lookup is unsuccessful'
        let(:students) { {'id' => ['61889']} }
        it_behaves_like 'a provider receiving an empty response'
      end

      context 'when given a single ID' do
        include_context 'when uid lookup is successful'
        let(:students) { {'id' => '61889'} }
        it 'returns an array of UIDs' do
          uids = subject.get_uids(event)
          expect(uids).to eq([uid])
        end
      end

      context 'when given an array of IDs' do
        include_context 'when uid lookup is successful'
        let(:students) { {'id' => ['61889']} }
        it 'returns an array of UIDs' do
          uids = subject.get_uids(event)
          expect(uids).to eq([uid])
        end
      end

    end
  end
end
