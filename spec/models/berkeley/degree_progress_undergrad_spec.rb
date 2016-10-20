describe Berkeley::DegreeProgressUndergrad do

  describe '#get_status' do
    subject { described_class.get_status(status_code) }

    context 'when status_code is nil' do
      let(:status_code) {nil}
      it {should be nil}
    end
    context 'when status_code is garbage' do
      let(:status_code) {'garbage'}
      it {should be nil}
    end
    context 'when status_code exists in @statuses' do
      let(:status_code) {'FAIL'}
      it {should eq 'Incomplete'}
    end
    context 'when status_code exists in @statuses but is lowercase' do
      let(:status_code) {'comp'}
      it {should eq 'Completed'}
    end
  end

  describe '#requirements_whitelist' do
    subject { described_class.requirements_whitelist }
    it {should eq [1, 2, 18, 3]}
  end

  describe '#get_description' do
    subject { described_class.get_description(requirement_code) }

    context 'when requirement_code is nil' do
      let(:requirement_code) {nil}
      it {should be nil}
    end
    context 'when requirement_code is not a number' do
      it 'should raise an error' do
        expect { described_class.get_description('garbage') }.to raise_error(ArgumentError)
      end
    end
    context 'when requirement_code exists in @requirements' do
      let(:requirement_code) {"0000001"}
      it {should eq 'Entry Level Writing'}
    end
  end

  describe '#get_order' do
    subject { described_class.get_order(requirement_code) }

    context 'when requirement_code is nil' do
      let(:requirement_code) {nil}
      it {should be nil}
    end
    context 'when requirement_code is not a number' do
      it 'should raise an error' do
        expect { described_class.get_order('garbage') }.to raise_error(ArgumentError)
      end
    end
    context 'when requirement_code exists in @requirements' do
      let(:requirement_code) {"00002"}
      it {should eq 1}
    end
  end
end
