describe Berkeley::ResidencyMessageCode do

  describe '.residency_message_code' do
    subject { described_class.residency_message_code(slr_status, residency_status, tuition_exception) }

    describe 'not yet submitted' do
      ['', 'PEND'].each do |res|
        let(:residency_status) {res}
        ['', 'N', 'X', 'ANYTHING'].each do |slr|
          context "when #{slr} slr_status" do
            let(:slr_status) {slr}
            let(:tuition_exception) { 'ANYTHING' }
            it {should eq '2000'}
          end
        end
      end
    end
    describe 'pending and submitted' do
      let(:residency_status) { 'PEND' }
      describe 'awaiting documents' do
        ['A', 'S'].each do |slr|
          context "when #{slr} slr_status" do
            let(:slr_status) {slr}
            let(:tuition_exception) { 'ANYTHING' }
            it {should eq '2001'}
          end
        end
      end
      describe 'documents received' do
        ['R'].each do |slr|
          context "when #{slr} slr_status" do
            let(:slr_status) {slr}
            let(:tuition_exception) { 'ANYTHING' }
            it {should eq '2002'}
          end
        end
      end
    end

    describe 'resident' do
      let(:residency_status) { 'RES' }
      let(:slr_status) { 'ANYTHING' }
      context 'when no tuition exception' do
        let(:tuition_exception) { '' }
        it {should eq '2003'}
      end
      describe 'classified for tuition' do
        ['R8', 'RP', 'RB'].each do |tuit|
          context "when #{tuit} tuition_exception" do
            let(:tuition_exception) {tuit}
            it {should eq '2006'}
          end
        end
      end
      describe 'submit each term' do
        ['RD', 'RDO', 'RDRA'].each do |tuit|
          context "when #{tuit} tuition_exception" do
            let(:tuition_exception) {tuit}
            it {should eq '2008'}
          end
        end
      end
      describe 'conditional' do
        ['R9', 'R6'].each do |tuit|
          context "when #{tuit} tuition_exception" do
            let(:tuition_exception) {tuit}
            it {should eq '2011'}
          end
        end
      end
    end

    describe 'non-resident' do
      let(:residency_status) { 'NON' }
      let(:slr_status) { 'ANYTHING' }
      context 'when no tuition exception' do
        let(:tuition_exception) { '' }
        it {should eq '2004'}
      end
      describe 'AB 540 or veteran' do
        ['RA', 'RV'].each do |tuit|
          context "when #{tuit} tuition_exception" do
            let(:tuition_exception) {tuit}
            it {should eq '2005'}
          end
        end
      end
      describe 'dependent law' do
        ['RP'].each do |tuit|
          context "when #{tuit} tuition_exception" do
            let(:tuition_exception) {tuit}
            it {should eq '2007'}
          end
        end
      end
      describe 'employee waiver' do
        ['RD', 'RL', 'RF', 'RDRA', 'RE'].each do |tuit|
          context "when #{tuit} tuition_exception" do
            let(:tuition_exception) {tuit}
            it {should eq '2009'}
          end
        end
      end
      describe 'military waiver' do
        ['RM'].each do |tuit|
          context "when #{tuit} tuition_exception" do
            let(:tuition_exception) {tuit}
            it {should eq '2010'}
          end
        end
      end
    end

    describe 'no match' do
      describe 'for non-resident when tuition_exception requires RES' do
        let(:slr_status) {'D'}
        let(:residency_status) { 'NON' }
        let(:tuition_exception) { 'R8' }
        it {should be_nil}
      end

      describe 'for resident when a tuition_exception requires NON' do
        let(:slr_status) {'Y'}
        let(:residency_status) { 'RES' }
        let(:tuition_exception) { 'RA' }
        it {should be_nil}
      end
    end
  end
end
