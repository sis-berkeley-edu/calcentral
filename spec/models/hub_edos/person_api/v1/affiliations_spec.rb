describe HubEdos::PersonApi::V1::Affiliations do
  let(:admit_affiliation) do
    {
      'type' => {
        'code' => 'ADMT_UX',
        'description' => 'Admitted student\'s access to Cal Central',
      },
      'detail' => 'Active',
      'status' => {
        'code' => 'ACT',
        'description' => 'Active',
      },
      'fromDate' => '2018-10-07',
    }
  end
  let(:alum_former_affiliation) do
    {
      'type' => {
        'code' => 'ALUMFORMER',
        'description' => 'Alum/Former Student',
      },
      'detail' => 'Former Student',
      'status' => {
        'code' => 'ACT',
        'description' => 'Active',
      },
      'fromDate' => '2019-04-12',
    }
  end
  let(:student_affiliation) do
    {
      'type' => {'code' => 'STUDENT'},
      'status' => {
        'code' => 'ACT',
        'description' => 'Active',
      },
      'fromDate' => '2020-05-19',
    }
  end
  let(:affiliations_data) do
    [
      admit_affiliation,
      alum_former_affiliation
    ]
  end
  subject { described_class.new(affiliations_data) }

  describe '#all' do
    its('all.count') { should eq(2) }
    it 'should return only affiliation objects' do
      subject.all.each do |identifier|
        expect(identifier).to be_an_instance_of HubEdos::PersonApi::V1::Affiliation
      end
    end
  end

  describe '#student_affiliation_present?' do
    context 'when collection includes student affiliation' do
      let(:affiliations_data) { [admit_affiliation, student_affiliation] }
      it 'returns true' do
        expect(subject.student_affiliation_present?).to eq true
      end
    end
    context 'when collection does not include student affiliation' do
      let(:affiliations_data) { [admit_affiliation, alum_former_affiliation] }
      it 'returns false' do
        expect(subject.student_affiliation_present?).to eq false
      end
    end
  end

  describe '#matriculated_but_excluded?' do
    let(:affiliation_1) { double('affiliation_1', :matriculated_but_excluded? => false) }
    let(:affiliation_2) { double('affiliation_2', :matriculated_but_excluded? => true) }
    let(:affiliations) { [affiliation_1, affiliation_2] }
    let(:result) { subject.matriculated_but_excluded? }
    before do
      allow(subject).to receive(:all).and_return(affiliations)
    end
    context 'when matriculated but excluded affiliation present' do
      let(:affiliations) { [affiliation_1, affiliation_2] }
      it 'returns true' do
        expect(result).to eq true
      end
    end
    context 'when matriculated but excluded affiliation is not present' do
      let(:affiliations) { [affiliation_1] }
      it 'returns false' do
        expect(result).to eq false
      end
    end
  end
end
