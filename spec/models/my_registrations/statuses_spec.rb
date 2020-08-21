describe MyRegistrations::Statuses do
  let(:uid) { '61889' }
  subject { MyRegistrations::Statuses.new(uid) }

  # ----------------------------
  # Stub Flagged Terms

  let(:current_term) do
    {
      id: '2195',
      name: 'Summer 2019',
      classesStart: DateTime.parse('Tue, 28 May 2019 00:00:00 -0700'),
      end: DateTime.parse('Fri, 16 Aug 2019 00:00:00 -0700'),
      endDropAdd: false,
      pastAddDrop: nil,
      pastClassesStart: true,
      pastEndOfInstruction: false,
      pastFinancialDisbursement: true
    }
  end
  let(:next_term) do
    {
      id: '2198',
      name: 'Fall 2019',
      classesStart: DateTime.parse('Wed, 28 Aug 2019 00:00:00 -0700'),
      end: DateTime.parse('Fri, 20 Dec 2019 00:00:00 -0800'),
      endDropAdd: DateTime.parse('2019-09-18 00:00:00 UTC'),
      pastAddDrop: false,
      pastClassesStart: false,
      pastEndOfInstruction: false,
      pastFinancialDisbursement: false
    }
  end
  let(:future_term) do
    {
      id: '2202',
      name: 'Spring 2020',
      classesStart: DateTime.parse('Tue, 21 Jan 2020 00:00:00 -0800'),
      end: DateTime.parse('Fri, 15 May 2020 00:00:00 -0700'),
      endDropAdd: DateTime.parse('2020-02-12 00:00:00 UTC'),
      pastAddDrop: false,
      pastClassesStart: false,
      pastEndOfInstruction: false,
      pastFinancialDisbursement: false
    }
  end
  let(:flagged_terms) do
    {
      current: current_term,
      running: current_term,
      sis_current_term: current_term,
      next: next_term,
      future: future_term,
    }
  end
  let(:flagged_terms_model) { double(:flagged_terms, get: flagged_terms) }
  before do
    allow(MyRegistrations::FlaggedTerms).to receive(:new).and_return(flagged_terms_model)
  end

  # ----------------------------
  # Stub Registrations
  let(:registrations) { [] }
  let(:registrations_feed) { {statusCode: 200, feed: {'registrations' => registrations}, studentNotFound: nil} }
  let(:registrations_proxy) { double(:registrations_proxy, get: registrations_feed) }
  before do
    allow(HubEdos::StudentApi::V2::Feeds::Registrations).to receive(:new).and_return(registrations_proxy)
  end

  # ----------------------------
  # Stub Positive Service Indicators

  let(:positive_service_indicators) { [] }
  let(:positive_service_indicators_model) { double(:positive_service_indicators_model, get: positive_service_indicators) }
  before do
    allow(MyRegistrations::PositiveServiceIndicators).to receive(:new).and_return(positive_service_indicators_model)
  end

  # ----------------------------
  # Stub Date/Time Settings

  let(:current_date_time) { nil }
  before(:each) do
    allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2016'
    allow(Settings.terms).to receive(:fake_now).and_return current_date_time
  end

  describe '#match_positive_indicators' do
    let(:term_registrations) { nil }
    let(:result) { subject.instance_exec(term_registrations) {|tr| match_positive_indicators(tr) } }
    context 'when term registrations present' do
      let(:term_registrations) do
        {
          '2198' => {
            'term' => {'id' => '2198', 'name' => 'Fall 2019'},
            'academicCareer' => {'code' => 'LAW', "description"=>"Law"},
            :termFlags=>{
              id: '2198',
              name: 'Fall 2019',
              classesStart: DateTime.parse('Wed, 28 Aug 2019 00:00:00 -0700'),
              end: DateTime.parse('Fri, 20 Dec 2019 00:00:00 -0800'),
              endDropAdd: DateTime.parse('Wed, 18 Sep 2019 00:00:00 +0000'),
              pastAddDrop: false,
              pastClassesStart: false,
              pastEndOfInstruction: false,
              pastFinancialDisbursement: false,
            }
          }
        }
      end
      context 'when positive service indicators present for term registrations' do
        let(:cnp_exception_indicator_spring_2018) do
          {
            'type' => {'code' => '+R99'},
            'fromTerm' => {'id' => '2182', 'name' => '2018 Spring'},
            'toTerm' => {'id' => '2182', 'name' => '2018 Spring'},
          }
        end
        let(:cnp_exception_indicator_spring_2018) do
          {
            'type' =>{'code' => '+R85'},
            'fromTerm' => {'id' => '2198', 'name' => '2019 Fall'},
            'toTerm' => {'id' => '2198', 'name' => '2019 Fall'},
          }
        end
        let(:positive_service_indicators) { [cnp_exception_indicator_spring_2018] }
        it 'adds positive term indicators to term registration' do
          expect(result['2198'][:positiveIndicators].count).to eq 1
          expect(result['2198'][:positiveIndicators][0]['type']['code']).to eq '+R85'
        end
      end
    end
    context 'when term registrations empty' do
      let(:term_registrations) { {} }
      it 'returns term registrations' do
        expect(result).to eq({})
      end
    end
  end

  describe '#set_summer_flags' do
    let(:term_registrations) do
      {
        '2195' => {
          'term' => {'id' => '2195', 'name' => 'Summer 2019'}
        },
        '2198' => {
          'term' => {'id' => '2198', 'name' => 'Fall 2019'}
        },
      }
    end
    let(:result) { subject.instance_exec(term_registrations) {|tr| set_summer_flags(tr) } }
    it 'flags term registrations with isSummer' do
      expect(subject).to receive(:edo_id_is_summer?).with('2195').and_return(true)
      expect(subject).to receive(:edo_id_is_summer?).with('2198').and_return(false)
      expect(result['2195'][:isSummer]).to eq true
      expect(result['2198'][:isSummer]).to eq false
    end
  end

  describe '#get_term_flag' do
    let(:term) do
      {
        termFlags: {
          pastAddDrop: true,
          pastClassesStart: false,
        }
      }
    end
    context 'when flags exist' do
      it 'returns expected flag' do
        result = subject.instance_exec(term, :pastAddDrop) {|t,f| get_term_flag(t, f) }
        expect(result).to eq true
        result = subject.instance_exec(term, :pastClassesStart) {|t,f| get_term_flag(t, f) }
        expect(result).to eq false
      end
    end
    context 'when flags do not exist' do
      let(:term) { {} }
      it 'returns nil' do
        result = subject.instance_exec(term, :pastAddDrop) {|t,f| get_term_flag(t, f) }
        expect(result).to eq nil
      end
    end
  end

  describe '#get_term_career' do
    let(:term) do
      {
        'academicCareer' => {
          'code' => 'UGRD'
        }
      }
    end
    it 'returns expected career code' do
      result = subject.instance_exec(term) {|t| get_term_career(t) }
      expect(result).to eq 'UGRD'
    end
  end

  describe '#extract_indicator_message' do
    let(:term) do
      {
        positiveIndicators: [
          {'type' => {'code' => '+R99'}, 'reason' => {'formalDescription' => 'CNP Exception'}},
          {'type' => {'code' => '+R85'}, 'reason' => {'formalDescription' => 'XYZ Exception'}},
          {'type' => {'code' => '+R45'}, 'reason' => {'formalDescription' => 'Great jorb'}},
        ]
      }
    end
    let(:indicator_type) { '+R45' }
    let(:result) { subject.instance_exec(term, indicator_type) {|t,i| extract_indicator_message(t,i) } }
    it 'returns formal description for matching indicator type code' do
      expect(result).to eq 'Great jorb'
    end
  end

  describe '#term_includes_r99_sf20?' do
    let(:result) { subject.instance_exec(term) {|t| term_includes_r99_sf20?(t) } }
    let(:term) do
      {
        positiveIndicators: [
          {'type' => {'code' => first_indicator_code}, 'reason' => {'code' => 'Some reason'}},
          {'type' => {'code' => second_indicator_code}, 'reason' => {'code' => 'SF20%'}},
        ]
      }
    end
    context 'term does not include +R99 indicator' do
      let(:first_indicator_code) { '+R85' }
      let(:second_indicator_code) { '+R45' }
      it 'returns false' do
        expect(result).to eq false
      end
    end
    context 'term includes +R99 indicator without SF20% reason code' do
      let(:first_indicator_code) { '+R99' }
      let(:second_indicator_code) { '+R45' }
      it 'returns false' do
        expect(result).to eq false
      end
    end
    context 'term includes +R99 indicator with SF20% reason code' do
      let(:first_indicator_code) { '+R45' }
      let(:second_indicator_code) { '+R99' }
      it 'returns false' do
        expect(result).to eq true
      end
    end
  end

  describe '#match_terms' do
    let(:result) { subject.instance_eval { match_terms(registrations, flagged_terms) } }
    context 'when terms are present' do
      let(:spring_2019_grad_registration) do
        {
          'term' => {'id' => '2192', 'name' => '2019 Spring'},
          'academicCareer' => {'code' => 'GRAD', 'description' => 'Graduate'},
        }
      end
    let(:fall_2019_grad_registration) do
        {
          'term' => {'id' => '2198', 'name' => '2019 Fall'},
          'academicCareer' => {'code' => 'GRAD', 'description' => 'Graduate'},
        }
      end
      context 'when registrations are nil' do
        let(:registrations) { nil }
        it 'returns empty hash' do
          expect(result).to eq({})
        end
      end
      context 'when registrations are empty' do
        let(:registrations) { [] }
        it 'returns empty hash' do
          expect(result).to eq({})
        end
      end
      context 'when registrations for non-active terms are present' do
        let(:registrations) { [spring_2019_grad_registration, fall_2019_grad_registration] }
        it 'does not return the registration for inactive term' do
          expect(result.has_key?('2192')).to eq false
        end
        it 'returns the matching term registrations' do
          expect(result['2198']['term']['id']).to eq '2198'
          expect(result['2198']['academicCareer']['code']).to eq 'GRAD'
        end
        it 'adds term flags and normalized term name to registration' do
          expect(result['2198']['term']['name']).to eq 'Fall 2019'
          expect(result['2198'][:termFlags][:id]).to eq '2198'
          expect(result['2198'][:termFlags][:name]).to eq 'Fall 2019'
          expect(result['2198'][:termFlags][:classesStart]).to eq DateTime.parse('Wed, 28 Aug 2019 00:00:00 -0700')
          expect(result['2198'][:termFlags][:end]).to eq DateTime.parse('Fri, 20 Dec 2019 00:00:00 -0800')
          expect(result['2198'][:termFlags][:endDropAdd]).to eq DateTime.parse('Wed, 18 Sep 2019 00:00:00 +0000')
          expect(result['2198'][:termFlags][:pastAddDrop]).to eq false
          expect(result['2198'][:termFlags][:pastClassesStart]).to eq false
          expect(result['2198'][:termFlags][:pastEndOfInstruction]).to eq false
          expect(result['2198'][:termFlags][:pastFinancialDisbursement]).to eq false
        end
      end
      context 'when two registrations for the same term are present' do
        let(:fall_2019_law_registration) do
          {
            'term' => {
              'id' => '2198',
              'name' => '2019 Fall',
            },
            'academicCareer' => {
              'code' => 'LAW',
              'description' => 'Law'
            },
          }
        end
        let(:registrations) { [fall_2019_grad_registration, fall_2019_law_registration] }
        it 'does not return the less relevant career registration' do
          expect(result['2198']['term']['id']).to eq '2198'
          expect(result['2198']['academicCareer']['code']).to_not eq 'GRAD'
        end
        it 'returns relevant career registration' do
          expect(result.keys).to eq ['2198']
          expect(result['2198']['term']['id']).to eq '2198'
          expect(result['2198']['academicCareer']['code']).to eq 'LAW'
        end
        it 'adds term flags and normalized term name to registration' do
          expect(result['2198']['term']['name']).to eq 'Fall 2019'
          expect(result['2198'][:termFlags][:id]).to eq '2198'
          expect(result['2198'][:termFlags][:name]).to eq 'Fall 2019'
          expect(result['2198'][:termFlags][:classesStart]).to eq DateTime.parse('Wed, 28 Aug 2019 00:00:00 -0700')
          expect(result['2198'][:termFlags][:end]).to eq DateTime.parse('Fri, 20 Dec 2019 00:00:00 -0800')
          expect(result['2198'][:termFlags][:endDropAdd]).to eq DateTime.parse('Wed, 18 Sep 2019 00:00:00 +0000')
          expect(result['2198'][:termFlags][:pastAddDrop]).to eq false
          expect(result['2198'][:termFlags][:pastClassesStart]).to eq false
          expect(result['2198'][:termFlags][:pastEndOfInstruction]).to eq false
          expect(result['2198'][:termFlags][:pastFinancialDisbursement]).to eq false
        end
      end
    end
    context 'when all terms are nil' do
      let(:current_term) { nil }
      let(:next_term) { nil }
      let(:future_term) { nil }
      it 'returns empty hash' do
        expect(result).to eq({})
      end
    end
  end

  describe '#find_relevant_career' do
    let(:result) { subject.instance_eval { find_relevant_career(registrations) } }
    context 'when no registrations provided' do
      let(:registrations) { [] }
      it 'returns nil' do
        expect(result).to eq nil
      end
    end
    context 'when only a single registration is provided' do
      let(:registrations) { [{'academicCareer' => {'code' => 'OVERGRD'}}] }
      it 'returns the registration' do
        expect(result['academicCareer']['code']).to eq 'OVERGRD'
      end
    end
    context 'when multiple registrations are provided' do
      let(:registrations) do
        [
          {'academicCareer' => {'code' => career1}},
          {'academicCareer' => {'code' => career2}},
        ]
      end
      context 'when registration in a valid career is not present' do
        let(:career1) { 'BOBLOBLAWLAWBLOG' }
        let(:career2) { 'OVERGRD' }
        it 'returns nil' do
          expect(result).to eq nil
        end
      end
      context 'when registration in relevant careers are present' do
        let(:career1) { 'GRAD' }
        let(:career2) { 'LAW' }
        it 'returns the most relevant registration' do
          expect(result['academicCareer']['code']).to eq 'LAW'
        end
      end
    end
  end

  describe '#flagged_terms' do
    it 'returns flagged terms' do
      result = subject.instance_eval { flagged_terms }
      expect(result[:current][:id]).to eq '2195'
      expect(result[:running][:id]).to eq '2195'
      expect(result[:sis_current_term][:id]).to eq '2195'
      expect(result[:next][:id]).to eq '2198'
      expect(result[:future][:id]).to eq '2202'
    end
    it 'memoizes flagged terms' do
      expect(MyRegistrations::FlaggedTerms).to receive(:new).once.and_return(flagged_terms_model)
      result1 = subject.instance_eval { flagged_terms }
      result2 = subject.instance_eval { flagged_terms }
      expect(result1[:current][:id]).to eq '2195'
      expect(result2[:current][:id]).to eq '2195'
    end
  end

  describe '#registrations' do
    let(:result) { subject.instance_eval { registrations } }
    let(:spring_2019_registration) { {'term' => {'id' => '2192', 'name' => '2019 Spring'}} }
    let(:fall_2019_registration) { {'term' => {'id' => '2198', 'name' => '2019 Fall'}} }
    let(:registrations) { [spring_2019_registration, fall_2019_registration] }
    it 'returns users registrations' do
      expect(result.count).to eq 2
      expect(result[0]['term']['id']).to eq '2192'
      expect(result[1]['term']['id']).to eq '2198'
    end
    context 'when registrations feed is nil' do
      let(:registrations) { nil }
      it 'returns empty array' do
        expect(result.count).to eq 0
        expect(result).to eq([])
      end
    end
    it 'memoizes users registrations' do
      expect(HubEdos::StudentApi::V2::Feeds::Registrations).to receive(:new).with({user_id: uid}).once.and_return(registrations_proxy)
      result2 = subject.instance_eval { registrations }
      [result, result2].each do |result|
        expect(result.count).to eq 2
        expect(result[0]['term']['id']).to eq '2192'
        expect(result[1]['term']['id']).to eq '2198'
      end
    end
  end
end
