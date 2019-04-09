describe MyRegistrations::SharedHelpers do

  def create_indicator_stub(indicator)
    {
      'type' => {
        'code' => indicator.to_s
      },
      'reason' => {
        'formalDescription' => "Hello there, I am #{indicator.to_s}"
      }
    }
  end
  let(:r99) { '+R99' }
  let(:s09) { '+S09' }

  describe '#extract_indicator_message' do
    let(:reg_stub) { { positiveIndicators: [ create_indicator_stub(s09) ] } }

    context 'when the registration contains the indicator' do
      subject { described_class.extract_indicator_message(reg_stub, s09) }
      it 'should return the formal description' do
        expect(subject).to eql('Hello there, I am +S09')
      end
    end

    context 'when the registration does not contain the indicator' do
      subject { described_class.extract_indicator_message(reg_stub, r99) }
      it 'should return nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#term_includes_indicator?' do
    let(:reg_stub) { { positiveIndicators: [ create_indicator_stub(r99) ] } }

    context 'when the registration contains the indicator' do
      subject { described_class.term_includes_indicator?(reg_stub, r99) }
      it 'should return true' do
        expect(subject).to be_truthy
      end
    end

    context 'when the registration does not contain the indicator' do
      subject { described_class.term_includes_indicator?(reg_stub, s09) }
      it 'should return false' do
        expect(subject).to be_falsey
      end
    end
  end
end
