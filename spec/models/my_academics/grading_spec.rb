describe MyAcademics::Grading do

  let(:uid) { '123456' }
  let(:fake) { true }

  subject do
    MyAcademics::Grading.new(uid)
  end

  context 'when grading period from settings is set' do
    before do
      allow(Settings.grading_period.general).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.general).to receive(:end).and_return '2016-12-12 23:59:59'
    end
    it 'it succeeds on grading period validation' do
      expect(subject.valid_grading_period?(false)).to eq true
    end
  end

  context 'when grading period start is bad format' do
    before do
      allow(Settings.grading_period.general).to receive(:start).and_return 'notadate'
      allow(Settings.grading_period.general).to receive(:end).and_return '2016-12-12 23:59:59'
    end
    it 'it fails on grading period validation' do
      expect(subject.valid_grading_period?(false)).to eq false
    end
  end

  context 'when grading period end is bad format' do
    before do
      allow(Settings.grading_period.general).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.general).to receive(:end).and_return 'notadate'
    end
    it 'it fails on grading period validation' do
      expect(subject.valid_grading_period?(false)).to eq false
    end
  end

  context 'when grading period start is not set' do
    before do
      allow(Settings.grading_period.general).to receive(:start).and_return ''
      allow(Settings.grading_period.general).to receive(:end).and_return '2016-12-12 23:59:59'
    end
    it 'it fails on grading period validation' do
      expect(subject.valid_grading_period?(false)).to eq false
    end
  end

  context 'when grading period end is not set' do
    before do
      allow(Settings.grading_period.general).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.general).to receive(:end).and_return ''
    end
    it 'it fails on grading period validation' do
      expect(subject.valid_grading_period?(false)).to eq false
    end
  end

  context 'when grading period end is before start' do
    before do
      allow(Settings.grading_period.general).to receive(:start).and_return '2016-12-12 23:59:59'
      allow(Settings.grading_period.general).to receive(:end).and_return '2016-12-12 0:0:0'
    end
    it 'it fails on grading period validation' do
      expect(subject.valid_grading_period?(false)).to eq false
    end
  end

  context 'when grading period is not valid' do
    before do
      allow(subject).to receive(:valid_grading_period?).and_return false
    end
    it 'it should return correct grading period status' do
      expect(subject.get_grading_period_status(false)).to eq :gradingPeriodNotSet
    end
  end

  context 'when current date is before grading period' do
    before do
      allow(Settings.grading_period.general).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.general).to receive(:end).and_return '2016-12-12 23:59:59'
      allow(DateTime).to receive(:now).and_return '2016-1-1 0:0:0'.to_datetime
    end
    it 'it should return correct grading period status' do
      expect(subject.get_grading_period_status(false)).to eq :beforeGradingPeriod
    end
  end

  context 'when current date is in grading period' do
    before do
      allow(Settings.grading_period.general).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.general).to receive(:end).and_return '2016-12-12 23:59:59'
      allow(DateTime).to receive(:now).and_return '2016-12-12 7:7:7'.to_datetime
    end
    it 'it should return correct grading period status' do
      expect(subject.get_grading_period_status(false)).to eq :inGradingPeriod
    end
  end

  context 'when current date is in grading period for Law' do
    before do
      allow(Settings.grading_period.general).to receive(:start).and_return 'notadate'
      allow(Settings.grading_period.general).to receive(:end).and_return 'notadate'
      allow(Settings.grading_period.law).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.law).to receive(:end).and_return '2016-12-12 23:59:59'
      allow(DateTime).to receive(:now).and_return '2016-12-12 7:7:7'.to_datetime
    end
    it 'it should return correct grading period status' do
      expect(subject.get_grading_period_status(true)).to eq :inGradingPeriod
    end
  end

  context 'when current date is after grading period' do
    before do
      allow(Settings.grading_period.general).to receive(:start).and_return '2016-12-12 0:0:0'
      allow(Settings.grading_period.general).to receive(:end).and_return '2016-12-12 23:59:59'
      allow(DateTime).to receive(:now).and_return '2017-1-1 0:0:0'.to_datetime
    end
    it 'it should return correct grading period status' do
      expect(subject.get_grading_period_status(false)).to eq :afterGradingPeriod
    end
  end

  context 'when CS provides grading status' do
    it 'it should validate correct CS status' do
      expect(subject.unexpected_cs_status?('GRD')).to eq false
    end

    it 'it should invalidate bad CS status' do
      expect(subject.unexpected_cs_status?('BAD')).to eq true
    end
  end

  context 'when parsing CS status codes from grading API' do
    let(:grading_proxy) { CampusSolutions::Grading.new(user_id: uid, fake: fake) }

    before do
      allow(CampusSolutions::Grading).to receive(:new).and_return(grading_proxy)
    end

    it 'it should return nil for missing ccn in sections' do
      expect(subject.get_cs_status(ccn = nil , term_code ='2168')).to eq nil
    end

    it 'it should return nil for missing term_code in sections' do
      expect(subject.get_cs_status(ccn = '123456' , term_code = nil)).to eq nil
    end

    it 'it should return expected for given term_code and ccn' do
      expect(subject.get_cs_status(ccn = '12666' , term_code = '2168')).to eq 'POST'
    end
  end

  context 'when mapping CC grading status to grading link' do
    let(:fake_grading_url) { 'http://fake.grading.com' }
    before do
      allow(MyAcademics::AcademicsModule).to receive(:fetch_link).and_return(fake_grading_url)
      allow(subject).to receive(:get_grading_period_status).and_return(:gradingPeriodNotSet)
    end

    it 'it should return nil for missing ccn in sections' do
      expect(subject.get_grading_link(ccn = nil , term_code ='2168', cc_grading_status = :noCsData, is_law = false)).to eq nil
    end

    it 'it should return nil for missing term_code in sections' do
      expect(subject.get_grading_link(ccn = '123456' , term_code = nil, cc_grading_status = :noCsData, is_law = false)).to eq nil
    end

    it 'it should return expected for given set grading period and no CS data' do
      expect(subject.get_grading_link(ccn = '12666' , term_code = '2168', cc_grading_status = :noCsData, is_law = false)).to eq nil
    end

    it 'it should return expected result with no set grading period and no CS data' do
      expect(subject.get_grading_link(ccn = '12666' , term_code = '2168', cc_grading_status = :noCsData, is_law = false)).to eq nil
    end

    it 'it should return expected result with no set grading period and CS status' do
      expect(subject.get_grading_link(ccn = '12666' , term_code = '2168', cc_grading_status = :POST, is_law = false)).to eq fake_grading_url
    end
  end

  context 'when grading returns statuses for a teaching semester' do
    let(:fake_grading_url) { 'http://fake.grading.com' }
    let(:uid) { '238382' }
    let(:grading_proxy) { CampusSolutions::Grading.new(user_id: uid, fake: fake) }
    let(:feed) { {}.tap { |feed| MyAcademics::Teaching.new(uid).merge feed } }

    before do
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2014'
      allow(Settings.features).to receive(:hub_term_api).and_return false
      allow(CampusSolutions::Grading).to receive(:new).and_return(grading_proxy)
      allow(MyAcademics::AcademicsModule).to receive(:fetch_link).and_return(fake_grading_url)
      allow(subject).to receive(:get_grading_period_status).and_return(:gradingPeriodNotSet)
    end

    it 'it should return expected values merged into section' do
      subject.merge(feed)
      expect(feed[:teachingSemesters][0][:classes][0][:sections][0][:gradingLink]).to eq fake_grading_url
      expect(feed[:teachingSemesters][0][:classes][0][:sections][0][:ccGradingStatus]).to eq :gradesSubmitted
      expect(feed[:teachingSemesters][0][:classes][0][:sections][0][:csGradingStatus]).to eq :POST

      expect(feed[:teachingSemesters][0][:classes][0][:sections][1][:gradingLink]).to eq nil
      expect(feed[:teachingSemesters][0][:classes][0][:sections][1][:ccGradingStatus]).to eq nil
      expect(feed[:teachingSemesters][0][:classes][0][:sections][1][:csGradingStatus]).to eq nil
    end

  end
end
