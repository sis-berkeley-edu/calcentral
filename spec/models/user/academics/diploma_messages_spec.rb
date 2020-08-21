describe User::Academics::DiplomaMessages do
  let(:paper_diploma_message) do
    {
      messageSetNbr: '28510',
      messageNbr: '1',
      messageText: 'Paper Diploma',
      msgSeverity: 'M',
      descrlong: 'You will receive an email once your diploma has been sent.'
    }
  end
  let(:electronic_diploma_notice_message) do
    {
      messageSetNbr: '28510',
      messageNbr: '2',
      messageText: 'Electronic Diploma',
      msgSeverity: 'M',
      descrlong: 'You will receive an email once your diploma is available for download.'
    }
  end
  let(:electronic_diploma_ready_message) do
    {
      messageSetNbr: '28510',
      messageNbr: '3',
      messageText: 'Electronic Diploma',
      msgSeverity: 'M',
      descrlong: 'Your electronic diploma is ready. To download your certified electronic paper diploma, click the button below.'
    }
  end
  let(:spring_2020_message) do
    {
      messageSetNbr: '28510',
      messageNbr: '2202',
      messageText: 'eDiploma Spring 2020',
      msgSeverity: 'M',
      descrlong: 'Test for Spring 2020 Diploma card'
    }
  end
  let(:summer_2020_message) do
    {
      messageSetNbr: '28510',
      messageNbr: '2205',
      messageText: 'eDiploma Summer 2020',
      msgSeverity: 'M',
      descrlong: 'Test for Summer 2020 Diploma card'
    }
  end
  let(:fall_2020_message) do
    {
      messageSetNbr: '28510',
      messageNbr: '2208',
      messageText: 'eDiploma Fall 2020',
      msgSeverity: 'M',
      descrlong: 'Test for Fall 2020 Diploma card'
    }
  end

  let(:term_ids) { ['2168','2202'] }
  subject { described_class.new(term_ids) }

  before do
    allow(CampusSolutions::MessageCatalog).to receive(:get_message_by).with(set: 28510, number: 1).and_return(paper_diploma_message)
    allow(CampusSolutions::MessageCatalog).to receive(:get_message_by).with(set: 28510, number: 2).and_return(electronic_diploma_notice_message)
    allow(CampusSolutions::MessageCatalog).to receive(:get_message_by).with(set: 28510, number: 3).and_return(electronic_diploma_ready_message)
    allow(CampusSolutions::MessageCatalog).to receive(:get_message_by).with(set: 28510, number: 2168).and_return(nil)
    allow(CampusSolutions::MessageCatalog).to receive(:get_message_by).with(set: 28510, number: 2202).and_return(spring_2020_message)
    allow(CampusSolutions::MessageCatalog).to receive(:get_message_by).with(set: 28510, number: 2205).and_return(summer_2020_message)
    allow(CampusSolutions::MessageCatalog).to receive(:get_message_by).with(set: 28510, number: 2208).and_return(fall_2020_message)
  end

  describe '#paper_diploma_message' do
    it 'returns paper diploma message' do
      expect(subject.paper_diploma_message[:messageText]).to eq 'Paper Diploma'
    end
  end

  describe '#electronic_diploma_notice_message' do
    it 'returns electronic diploma notice message' do
      expect(subject.electronic_diploma_notice_message[:messageNbr]).to eq '2'
      expect(subject.electronic_diploma_notice_message[:messageText]).to eq 'Electronic Diploma'
    end
  end

  describe '#electronic_diploma_ready_message' do
    it 'returns electronic diploma ready message' do
      expect(subject.electronic_diploma_ready_message[:messageNbr]).to eq '3'
      expect(subject.electronic_diploma_ready_message[:messageText]).to eq 'Electronic Diploma'
    end
  end

  describe '#supported_terms' do
    it 'returns term ids supported for diploma' do
      expect(subject.supported_terms).to eq(['2202'])
    end
  end

  describe '#greatest_supported_term' do
    let(:term_ids) { ['2168','2202','2208'] }
    it 'returns greatest supported term id' do
      expect(subject.greatest_supported_term).to eq '2208'
    end
  end

  describe '#electronic_diploma_help_message' do
    let(:term_ids) { ['2168','2202','2208'] }
    it 'returns message for greatest supported term id' do
      expect(subject.electronic_diploma_help_message[:messageSetNbr]).to eq '28510'
      expect(subject.electronic_diploma_help_message[:messageNbr]).to eq '2208'
    end
  end

  describe '#term_help_messages' do
    let(:result) { subject.term_help_messages }
    it 'returns hash without fall 2016 key and value' do
      expect(result.has_key?('2168')).to eq false
      expect(result['2168']).to eq nil
    end
    it 'returns hash with spring 2020 key and message' do
      expect(result.has_key?('2202')).to eq true
      expect(result['2202'][:messageSetNbr]).to eq '28510'
      expect(result['2202'][:messageNbr]).to eq '2202'
      expect(result['2202'][:messageText]).to eq 'eDiploma Spring 2020'
      expect(result['2202'][:msgSeverity]).to eq 'M'
      expect(result['2202'][:descrlong]).to eq 'Test for Spring 2020 Diploma card'
    end
  end
end
