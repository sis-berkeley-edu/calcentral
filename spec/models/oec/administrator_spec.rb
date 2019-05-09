describe Oec::Administrator do
  let(:uid) { nil }
  before {
    allow(Settings.oec).to receive(:administrator_uid).and_return oec_admin_uid
  }
  subject { Oec::Administrator.is_admin? uid }

  shared_examples 'failed authentication' do
    it 'should return false' do
      expect(subject).to be false
    end
  end
  context 'YAML is missing oec.administrator_uid' do
    let(:oec_admin_uid) { '' }

    it_behaves_like 'failed authentication'

    context 'empty uid' do
      let(:uid) { '' }
      it_behaves_like 'failed authentication'
    end
  end
  context 'YAML has a valid OEC administrator_uid' do
    let(:oec_admin_uid) { random_id }
    let(:uid) { ' ' }

    it_behaves_like 'failed authentication'

    context 'uid is not matching' do
      let(:uid) { '12E45' }
      it_behaves_like 'failed authentication'
    end
    context 'uid is matching' do
      let(:uid) { oec_admin_uid.to_i }
      it 'should return true' do
        expect(subject).to be true
      end
    end
  end
end
