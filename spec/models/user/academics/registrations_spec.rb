describe User::Academics::Registrations do
  let(:uid) { random_id }
  let(:registrations_feed) do
    {
      statusCode: 200,
      feed: {
        'registrations' => [
          {'term' => {'id' => '2198'}, 'academicCareer' => {'code' => 'LAW'}},
          {'term' => {'id' => '2195'}, 'academicCareer' => {'code' => 'UGRD'}},
          {'term' => {'id' => '2192'}, 'academicCareer' => {'code' => 'UGRD'}},
        ]
      }
    }
  end
  let(:registrations_proxy) { double(:registrations_proxy, get: registrations_feed) }
  let(:user) { User::Current.new(uid) }
  before { allow(HubEdos::StudentApi::V2::Feeds::Registrations).to receive(:new).and_return(registrations_proxy) }
  subject { described_class.new(user) }

  describe '#all' do
    it 'returns all registrations sorted by term id' do
      result = subject.all
      expect(result.collect(&:term_id)).to eq ['2192', '2195', '2198']
    end
  end

  describe '#latest' do
    let(:registrations) { [] }
    before { allow(subject).to receive(:data_feed).and_return(registrations) }
    context 'when no registrations in student data' do
      let(:registrations) { [] }
      it 'returns empty array' do
        expect(subject.latest).to eq []
      end
    end
    context 'when single registration for latest term' do
      let(:registrations) do
        [
          {'term' => {'id' => '2185'}, 'academicCareer' => {'code' => 'GRAD'}},
          {'term' => {'id' => '2192'}, 'academicCareer' => {'code' => 'GRAD'}},
          {'term' => {'id' => '2188'}, 'academicCareer' => {'code' => 'GRAD'}},
        ]
      end
      it 'returns the latest registration' do
        result = subject.latest
        expect(result.count).to eq 1
        expect(result.first.term_id).to eq '2192'
        expect(result.first.career_code).to eq 'GRAD'
      end
    end
    context 'when multiple registrations for latest term' do
      let(:registrations) do
        [
          {'term' => {'id' => '2185'}, 'academicCareer' => {'code' => 'GRAD'}},
          {'term' => {'id' => '2188'}, 'academicCareer' => {'code' => 'GRAD'}},
          {'term' => {'id' => '2192'}, 'academicCareer' => {'code' => 'GRAD'}},
          {'term' => {'id' => '2192'}, 'academicCareer' => {'code' => 'LAW'}},
        ]
      end
      it 'returns both registrations' do
        result = subject.latest
        expect(result.count).to eq 2
        expect(result[0].term_id).to eq '2192'
        expect(result[0].career_code).to eq 'GRAD'
        expect(result[1].term_id).to eq '2192'
        expect(result[1].career_code).to eq 'LAW'
      end
    end
  end

  describe '#latest_term_id' do
    let(:registrations) do
      [
        {'term' => {'id' => '2185'}, 'academicCareer' => {'code' => 'GRAD'}},
        {'term' => {'id' => '2188'}, 'academicCareer' => {'code' => 'GRAD'}},
        {'term' => {'id' => '2192'}, 'academicCareer' => {'code' => 'GRAD'}},
        {'term' => {'id' => '2192'}, 'academicCareer' => {'code' => 'LAW'}},
      ]
    end
    before { allow(subject).to receive(:data_feed).and_return(registrations) }
    it 'returns latest registration term id' do
      expect(subject.latest_term_id).to eq '2192'
    end
  end

  describe '#data_feed' do
    it 'loads raw registrations data' do
      result = subject.data_feed
      expect(result.count).to eq 3
    end
    it 'memoizes registration proxy data' do
      expect(HubEdos::StudentApi::V2::Feeds::Registrations).to receive(:new).once.and_return(registrations_proxy)
      result1 = subject.data_feed
      result2 = subject.data_feed
      expect(result1.count).to eq 3
      expect(result2.count).to eq 3
    end
  end
end
