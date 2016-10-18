describe Berkeley::DegreeProgress do

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
      let(:status_code) {'Y'}
      it {should eq 'Completed'}
    end
    context 'when status_code exists in @statuses but is lowercase' do
      let(:status_code) {'n'}
      it {should eq 'Not Satisfied'}
    end
  end

  describe '#get_description' do
    subject { described_class.get_description(milestone_code) }

    context 'when milestone_code is nil' do
      let(:milestone_code) {nil}
      it {should be nil}
    end
    context 'when milestone_code is garbage' do
      let(:milestone_code) {'garbage'}
      it {should be nil}
    end
    context 'when milestone_code exists in @statuses' do
      let(:milestone_code) {'AAGADVMAS1'}
      it {should eq 'Advancement to Candidacy Plan I'}
    end
    context 'when milestone_code exists in @statuses but is lowercase' do
      let(:milestone_code) {'aagdissert'}
      it {should eq 'Dissertation File Date'}
    end
  end
end
