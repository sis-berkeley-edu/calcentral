describe MyRegistrations::PositiveServiceIndicators do
  subject { described_class.new(uid) }
  let(:uid) { random_id }
  let(:student_attributes_proxy) { double(:student_attributes, :get => student_attributes_feed)}
  let(:student_attributes_feed) do
    {
      statusCode: 200,
      feed: {'studentAttributes' => student_attributes},
      studentNotFound: nil
    }
  end
  let(:student_attributes) { [] }
  let(:american_institutions_indicator) do
    {
      'type' => {
        'code' => 'AIC',
        'description' => 'Amer Institutions - Completed'
      },
      'fromDate' => '2017-04-18'
    }
  end
  let(:american_history_indicator) do
    {
      'type' => {
        'code' => 'AHC',
        'description' => 'American History - Completed'
      },
      'fromDate' => '2017-04-18'
    }
  end
  let(:cnp_exception_indicator) do
    {
      'type' => {'code' => '+R99', 'description' => 'CNP Exception'},
      'reason' => {'code' => 'FARVW', 'description' => 'Exception from CNP'},
      'fromTerm' => {
        'id' => '2172',
        "name"=>"2017 Spring",
        "beginDate"=>"2017-01-10",
        "endDate"=>"2017-05-12"
      },
      'toTerm' => {
        'id' => '2172',
        "name"=>"2017 Spring",
        "beginDate"=>"2017-01-10",
        "endDate"=>"2017-05-12"
      },
      'fromDate' => '2017-01-12'
    }
  end
  before do
    allow(HubEdos::StudentApi::V2::Feeds::StudentAttributes).to receive(:new).and_return(student_attributes_proxy)
  end

  describe '#get' do
    let(:student_attributes) { [american_history_indicator, cnp_exception_indicator, american_institutions_indicator] }
    let(:result) { subject.get }
    it 'returns positive indicators' do
      expect(result.count).to eq 1
      expect(result.first['type']['code']).to eq '+R99'
    end
    it 'performs check on dates for positive indicators' do
      expect(subject).to receive(:check_indicator_dates).once.and_return(nil)
      expect(result.count).to eq 1
    end
  end

  describe '#student_attributes' do
    let(:student_attributes) { [cnp_exception_indicator] }
    let(:result) { subject.student_attributes }
    it 'returns student attributes from feed' do
      expect(result.count).to eq 1
      expect(result.first['type']['code']).to eq '+R99'
      expect(result.first['reason']['code']).to eq 'FARVW'
      expect(result.first['fromTerm']['id']).to eq '2172'
      expect(result.first['toTerm']['id']).to eq '2172'
    end
    it 'memoizes student attributes' do
      expect(HubEdos::StudentApi::V2::Feeds::StudentAttributes).to receive(:new).once.and_return(student_attributes_proxy)
      result1 = subject.student_attributes
      result2 = subject.student_attributes
      expect(result1.count).to eq 1
      expect(result2.count).to eq 1
      expect(result1.first['type']['code']).to eq '+R99'
      expect(result1.first['reason']['code']).to eq 'FARVW'
      expect(result1.first['fromTerm']['id']).to eq '2172'
      expect(result1.first['toTerm']['id']).to eq '2172'
      expect(result2.first['type']['code']).to eq '+R99'
      expect(result2.first['reason']['code']).to eq 'FARVW'
      expect(result2.first['fromTerm']['id']).to eq '2172'
      expect(result2.first['toTerm']['id']).to eq '2172'
    end
  end

  describe '#check_indicator_dates' do
    context 'when positive indicator applies to a single term' do
      let(:indicator) { cnp_exception_indicator }
      it 'does not log warning' do
        expect(subject).to_not receive(:logger)
        subject.check_indicator_dates(indicator)
      end
    end
    context 'when positive indicator applies to multiple terms' do
      let(:indicator) do
        {
          'type' => {'code' => '+R99'},
          'fromTerm' => {'id' => '2172'},
          'toTerm' => {'id' => '2175'},
        }
      end
      it 'logs warning with indicator details' do
        expected_message = "Positive service indicator spanning multiple terms found for #{uid}. Indicator: +R99, termStart ID: 2172, termEnd ID: 2175. Using termStart ID to parse registration status."
        logger = double(:logger)
        expect(logger).to receive(:warn).with(expected_message)
        expect(subject).to receive(:logger).and_return(logger)
        subject.check_indicator_dates(indicator)
      end
    end
  end

  describe '#is_positive_service_indicator?' do
    let(:result) { subject.is_positive_service_indicator? attribute }
    context 'when type code starts with a +' do
      let(:attribute) { {'type'=>{'code'=>'+ABCD'}} }
      it 'returns true' do
        expect(result).to eq true
      end
    end
    context 'when type code does not start with a +' do
      let(:attribute) { {'type'=>{'code'=>'ABCD'}} }
      it 'returns false' do
        expect(result).to eq false
      end
    end
  end

end
