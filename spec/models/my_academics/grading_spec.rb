describe MyAcademics::Grading do

  let(:uid) { '123456' }
  let(:fake) { true }
  let(:fake_grading_url) do
    {
      url: 'http://fake.grading.com'
    }
  end
  let(:link_proxy_class) { CampusSolutions::Link }
  let(:link_fake_proxy) { link_proxy_class.new(fake: true) }
  let(:fake_spring_term) { double(is_summer: false, :year => 2015, :code => 'B') }

  subject do
    MyAcademics::Grading.new(uid)
  end

  before do
    allow(Settings.terms).to receive(:fake_now).and_return nil
    allow(link_proxy_class).to receive(:new).and_return link_fake_proxy
    allow(link_fake_proxy).to receive(:get_url).and_return({link: fake_grading_url})
  end

  context 'when grading period from settings is set' do
    before do
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:end).and_return '2016-12-12 23:59:59'
    end
    it 'it succeeds on grading period validation' do
      expect(subject.valid_grading_period?(false, '2168')).to eq true
    end
  end

  context 'when grading period start is bad format' do
    before do
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:start).and_return 'notadate'
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:end).and_return '2016-12-12 23:59:59'
    end
    it 'it fails on grading period validation' do
      expect(subject.valid_grading_period?(false, '2168')).to eq false
    end
  end

  context 'when grading period end is bad format' do
    before do
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:end).and_return 'notadate'
    end
    it 'it fails on grading period validation' do
      expect(subject.valid_grading_period?(false, '2168')).to eq false
    end
  end

  context 'when grading period start is not set' do
    before do
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:start).and_return ''
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:end).and_return '2016-12-12 23:59:59'
    end
    it 'it fails on grading period validation' do
      expect(subject.valid_grading_period?(false, '2168')).to eq false
    end
  end

  context 'when grading period end is not set' do
    before do
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:end).and_return ''
    end
    it 'it fails on grading period validation' do
      expect(subject.valid_grading_period?(false, '2168')).to eq false
    end
  end

  context 'when grading period end is before start' do
    before do
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:start).and_return '2016-12-12 23:59:59'
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:end).and_return '2016-12-12 0:0:0'
    end
    it 'it fails on grading period validation' do
      expect(subject.valid_grading_period?(false, '2168')).to eq false
    end
  end

  context 'when grading period is not valid' do
    before do
      allow(subject).to receive(:valid_grading_period?).and_return false
    end
    it 'it should return correct grading period status' do
      expect(subject.get_grading_period_status(false, false, '2168')).to eq :gradingPeriodNotSet
    end
  end

  context 'when current date is before grading period' do
    before do
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:end).and_return '2016-12-12 23:59:59'
      allow(DateTime).to receive(:now).and_return '2016-1-1 0:0:0'.to_datetime
    end
    it 'it should return correct grading period status' do
      expect(subject.get_grading_period_status(false, false, '2168')).to eq :beforeGradingPeriod
    end
  end

  context 'when current date is in grading period' do
    before do
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:end).and_return '2016-12-12 23:59:59'
      allow(DateTime).to receive(:now).and_return '2016-12-12 7:7:7'.to_datetime
    end
    it 'it should return correct grading period status' do
      expect(subject.get_grading_period_status(false, false, '2168')).to eq :inGradingPeriod
    end
  end

  context 'when current date is in grading period for Law' do
    before do
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:start).and_return 'notadate'
      allow(Settings.grading_period.dates.general.fall_2016).to receive(:end).and_return 'notadate'
      allow(Settings.grading_period.dates.law.fall_2016).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.dates.law.fall_2016).to receive(:end).and_return '2016-12-12 23:59:59'
      allow(DateTime).to receive(:now).and_return '2016-12-12 7:7:7'.to_datetime
    end
    it 'it should return correct grading period status' do
      expect(subject.get_grading_period_status(true, false, '2168')).to eq :inGradingPeriod
    end
  end

  context 'when current date is after grading period' do
    before do
      allow(Settings.grading_period.dates.general.spring_2017.midpoint).to receive(:start).and_return '2016-12-01 0:0:0'
      allow(Settings.grading_period.dates.general.spring_2017.midpoint).to receive(:end).and_return '2016-12-05 23:59:59'
      allow(Settings.grading_period.dates.general.spring_2017.final).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.dates.general.spring_2017.final).to receive(:end).and_return '2016-12-12 23:59:59'
      allow(DateTime).to receive(:now).and_return '2017-1-1 0:0:0'.to_datetime
    end
    it 'it should return correct grading period status' do
      expect(subject.get_grading_period_status(false, false, '2172')).to eq :afterGradingPeriod
    end
  end

  context 'when CS provides grading status' do
    it 'it should validate correct CS status' do
      expect(subject.unexpected_cs_status?({finalStatus: 'GRD'}, true)).to eq false
    end

    it 'it should invalidate bad CS status' do
      expect(subject.unexpected_cs_status?({finalStatus: 'BAD'}, true)).to eq true
    end
  end

  context 'when parsing CS status codes from grading API' do
    let(:grading_proxy) { CampusSolutions::Grading.new(user_id: uid, fake: fake) }

    before do
      allow(CampusSolutions::Grading).to receive(:new).and_return(grading_proxy)
    end

    it 'it should return nil for missing ccn in sections' do
      expect(subject.get_cs_status(ccn = nil, is_law = false, term_code ='2168')).to eq nil
    end

    it 'it should return nil for missing term_code in sections' do
      expect(subject.get_cs_status(ccn = '123456', is_law = false, term_code = nil)).to eq nil
    end

    it 'it should return expected for given term_code and ccn' do
      expect(subject.get_cs_status(ccn = '12666', is_law = false, term_code = '2168')).to eq({:midpointStatus=>"NRVW", :finalStatus=>"POST"})
    end
  end

  context 'when mapping CC grading status to grading link' do
    before do
      allow(subject).to receive(:get_grading_period_status).and_return(:gradingPeriodNotSet)
    end

    it 'it should return nil for missing ccn in sections' do
      expect(subject.get_grading_link(ccn = nil , term_code ='2168', cc_grading_status = {finalStatus: :noCsData})).to eq nil
    end

    it 'it should return nil for missing term_code in sections' do
      expect(subject.get_grading_link(ccn = '123456' , term_code = nil, cc_grading_status = {finalStatus: :noCsData})).to eq nil
    end

    it 'it should return expected for given set grading period and no CS data' do
      expect(subject.get_grading_link(ccn = '12666' , term_code = '2168', cc_grading_status = {finalStatus: :noCsData})).to eq nil
    end

    it 'it should return expected result with no set grading period and no CS data' do
      expect(subject.get_grading_link(ccn = '12666' , term_code = '2168', cc_grading_status = {finalStatus: :noCsData})).to eq nil
    end

    it 'it should return expected result with no set grading period and CS status' do
      expect(subject.get_grading_link(ccn = '12666' , term_code = '2168', cc_grading_status = {finalStatus: :POST})).to eq fake_grading_url
    end
  end

  context 'when grading returns statuses for a teaching semester' do
    let(:uid) { '238382' }
    let(:grading_proxy) { CampusSolutions::Grading.new(user_id: uid, fake: fake) }
    let(:teaching_proxy) { MyAcademics::Teaching.new(uid) }
    before { allow(teaching_proxy).to receive(:current_term).and_return(fake_spring_term) }
    let(:feed) { {}.tap { |feed| teaching_proxy.merge feed } }

    before do
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2014'
      allow(CampusSolutions::Grading).to receive(:new).and_return(grading_proxy)
      allow(subject).to receive(:get_grading_period_status).and_return(:gradingPeriodNotSet)
      stub_const("MyAcademics::Grading::ACTIVE_GRADING_TERMS", ['2138'])
    end

    it 'it should return expected values merged into section', :if => CampusOracle::Connection.test_data? do
      subject.merge(feed)
      expect(feed[:teachingSemesters][0][:classes][0][:sections][0][:gradingLink]).to eq fake_grading_url
      expect(feed[:teachingSemesters][0][:classes][0][:sections][0][:ccGradingStatus]).to eq :gradesPosted
      expect(feed[:teachingSemesters][0][:classes][0][:sections][0][:csGradingStatus]).to eq :POST
      expect(feed[:teachingSemesters][0][:classes][0][:sections][1][:gradingLink]).to eq nil
      expect(feed[:teachingSemesters][0][:classes][0][:sections][1][:ccGradingStatus]).to eq nil
      expect(feed[:teachingSemesters][0][:classes][0][:sections][1][:csGradingStatus]).to eq nil
    end
  end

  context 'when grading for a summer term' do

    let(:uid) { '904715' }
    let(:grading_proxy) { CampusSolutions::Grading.new(user_id: uid, fake: fake) }
    let(:teaching_proxy) { MyAcademics::Teaching.new(uid) }
    before { allow(teaching_proxy).to receive(:current_term).and_return(fake_spring_term) }
    let(:feed) { {}.tap { |feed| teaching_proxy.merge feed } }

    before do
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2014'
      allow(CampusSolutions::Grading).to receive(:new).and_return(grading_proxy)
      allow(subject).to receive(:parse_cs_grading_status).and_return ({ finalStatus: :GRD })
      allow(subject).to receive(:get_grading_period_status_summer).and_return :afterGradingPeriod
      stub_const("MyAcademics::Grading::ACTIVE_GRADING_TERMS", ['2145'])
    end

    it 'should use the summer-specific function to parse grading status', :if => CampusOracle::Connection.test_data? do
      subject.merge(feed)
      expect(feed[:teachingSemesters][0][:classes][0][:sections][0][:gradingLink]).to eq fake_grading_url
      expect(feed[:teachingSemesters][0][:classes][0][:sections][0][:csGradingStatus]).to eq :GRD
      expect(feed[:teachingSemesters][0][:classes][0][:sections][0][:ccGradingStatus]).to eq :gradesOverdue
    end
  end
end
