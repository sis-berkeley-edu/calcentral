describe User::HasInstructorHistory do
  let(:uid) { '2050' }

  describe 'has_instructor_history?' do
    let(:legacy_term) { double(:term, :legacy? => true) }
    let(:sisedo_term) { double(:term, :legacy? => false) }
    let(:current_terms) { [sisedo_term, legacy_term] }
    let(:is_legacy_instructor) { false }
    let(:is_sisedo_instructor) { false }
    before do
      allow(CampusOracle::Queries).to receive(:has_instructor_history?).and_return(is_legacy_instructor)
      allow(EdoOracle::Queries).to receive(:has_instructor_history?).and_return(is_sisedo_instructor)
    end
    subject { described_class.new(uid).has_instructor_history?(current_terms) }

    context 'when user is not an instructor in legacy or sisedo systems' do
      it {should eq false}
    end

    context 'when user is an instructor in legacy system' do
      let(:is_legacy_instructor) { true }
      it {should eq true}
    end

    context 'when user is an instructor in sisedo system' do
      let(:is_sisedo_instructor) { true }
      it {should eq true}
    end
  end

end
