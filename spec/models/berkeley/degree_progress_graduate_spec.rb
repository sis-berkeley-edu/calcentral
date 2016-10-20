describe Berkeley::DegreeProgressGraduate do

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

  describe '#get_form_notification' do
    subject { described_class.get_form_notification(milestone_code, status_code) }

    context 'when milestone_code is nil' do
      let(:milestone_code) {nil}
      let(:status_code) {'N'}
      it {should be nil}
    end
    context 'when milestone_code is garbage' do
      let(:milestone_code) {'garbage'}
      let(:status_code) {'N'}
      it {should be nil}
    end
    context 'when milestone is completed' do
      let(:milestone_code) {'AAGADVMAS1'}
      let(:status_code) {'Y'}
      it {should be nil}
    end
    context 'when milestone_code exists in @statuses' do
      let(:milestone_code) {'AAGADVMAS1'}
      let(:status_code) {'N'}
      it {should eq '(Form Required)'}
    end
    context 'when milestone_code exists in @statuses but is lowercase' do
      let(:milestone_code) {'aagqeaprv'}
      let(:status_code) {'N'}
      it {should eq '(Form Required)'}
    end
  end
end
