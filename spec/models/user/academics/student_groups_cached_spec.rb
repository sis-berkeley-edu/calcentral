describe User::Academics::StudentGroupsCached do
  let(:uid) { random_id }
  let(:user) { User::Current.new(uid) }
  subject { described_class.new(user) }

  it 'returns uid as instance key' do
    expect(subject.instance_key).to eq uid
  end
end
