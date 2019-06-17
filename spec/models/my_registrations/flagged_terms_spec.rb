describe MyRegistrations::FlaggedTerms do
  let(:current_term) do
    double(:current_term, {
      campus_solutions_id: '2195',
      to_english: 'Summer 2019',
      classes_start: DateTime.parse('Tue, 28 May 2019 00:00:00 -0700'),
      end: DateTime.parse('Fri, 16 Aug 2019 00:00:00 -0700'),
      end_drop_add: false,
    })
  end
  let(:next_term) do
    double(:running_term, {
      campus_solutions_id: '2198',
      to_english: 'Fall 2019',
      classes_start: DateTime.parse('Wed, 28 Aug 2019 00:00:00 -0700'),
      end: DateTime.parse('Fri, 20 Dec 2019 00:00:00 -0800'),
      end_drop_add: Date.parse('2019-09-18 00:00:00 UTC'),
    })
  end
  let(:future_term) do
    double(:future_term, {
      campus_solutions_id: '2202',
      to_english: 'Spring 2020',
      classes_start: DateTime.parse('Tue, 21 Jan 2020 00:00:00 -0800'),
      end: DateTime.parse('Fri, 15 May 2020 00:00:00 -0700'),
      end_drop_add: Date.parse('2020-02-12 00:00:00 UTC'),
    })
  end
  let(:berkeley_terms) do
    double(:berkeley_terms, {
      current: current_term,
      running: current_term,
      sis_current_term: current_term,
      next: next_term,
      future: future_term,
    })
  end
  let(:fake_now) { Concerns::DatesAndTimes.cast_utc_to_pacific(DateTime.parse('2019-08-02')) }
  before do
    allow(Berkeley::Terms).to receive(:fetch).and_return(berkeley_terms)
    allow(Settings.terms).to receive(:fake_now).and_return(fake_now)
  end

  describe '.get' do
    let(:result) { subject.get }
    context 'when all terms are present' do
      it 'provides term attributes' do
        expect(result).to be
        expect(result[:current][:id]).to eq '2195'
        expect(result[:running][:id]).to eq '2195'
        expect(result[:sis_current_term][:id]).to eq '2195'
        expect(result[:next][:id]).to eq '2198'
        expect(result[:future][:id]).to eq '2202'
      end
      it 'provides term flags' do
        expect(result[:current][:pastClassesStart]).to eq true
        expect(result[:current][:pastAddDrop]).to eq nil
        expect(result[:current][:pastFinancialDisbursement]).to eq true
        expect(result[:current][:pastEndOfInstruction]).to eq false
        expect(result[:next][:pastClassesStart]).to eq false
        expect(result[:next][:pastAddDrop]).to eq false
        expect(result[:next][:pastFinancialDisbursement]).to eq false
        expect(result[:next][:pastEndOfInstruction]).to eq false
        expect(result[:future][:pastClassesStart]).to eq false
        expect(result[:future][:pastAddDrop]).to eq false
        expect(result[:future][:pastFinancialDisbursement]).to eq false
        expect(result[:future][:pastEndOfInstruction]).to eq false
      end
    end
    context 'when a term is not present' do
      let(:next_term) { nil }
      let(:future_term) { nil }
      it 'provides nil value for term' do
        expect(result[:current][:id]).to eq '2195'
        expect(result[:next]).to eq nil
        expect(result[:future]).to eq nil
      end
    end
  end
end
