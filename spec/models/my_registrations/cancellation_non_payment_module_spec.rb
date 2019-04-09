describe MyRegistrations::CancellationNonPaymentModule do
  let(:stubbed_term_reg) {
    {
      '2182' => {
        :isSummer => false,
        :regStatus => {
          :summary => 'Not Officially Registered'
        }
      },
      '2185' => {
        :isSummer => false,
        :regStatus => {
          :summary => 'Officially Registered'
        }
      }
    }
  }

  describe '#set_cnp_flags' do
    context 'when true' do
      before { allow(described_class).to receive(:show_cnp?).and_return true }
      subject { described_class.set_cnp_flags(stubbed_term_reg) }
      it 'sets the correct flag value' do
        expect(subject['2182'][:showCnp]).to eql(true)
      end
    end

    context 'when false' do
      before { allow(described_class).to receive(:show_cnp?).and_return false }
      subject { described_class.set_cnp_flags(stubbed_term_reg) }
      it 'still sets the value as false' do
        expect(subject['2182'][:showCnp]).to eql(false)
      end
    end
  end

  describe '#show_cnp?' do
    before do
      allow(described_class).to receive(:get_term_career).and_return career
      allow(described_class).to receive(:get_term_flag).and_return past_classes_start
      allow(described_class).to receive(:term_includes_indicator?).and_return true
    end

    context 'as an undergraduate' do
      let(:career) { 'UGRD' }
      context 'before classes have started' do
        let (:past_classes_start) { false }
        context 'registered' do
          subject { described_class.show_cnp?(stubbed_term_reg['2185']) }
          it 'returns false' do
            expect(subject).to eql(false)
          end
        end
        context 'not registered' do
          subject { described_class.show_cnp?(stubbed_term_reg['2182']) }
          it 'returns true' do
            expect(subject).to eql(true)
          end
        end
      end
    end
    context 'as a non-undergraduate' do
      let(:career) { 'GRAD' }
      let(:past_classes_start) { true }
      subject { described_class.show_cnp?(stubbed_term_reg['2185']) }
      it 'returns false regardless' do
        expect(subject).to eql(false)
      end
    end

  end
end
