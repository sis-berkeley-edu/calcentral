describe EdoOracle::FinancialAid::Queries do
  shared_examples 'a successful query' do
    it 'returns a set of rows' do
      expect(subject).to be
      expect(subject).to be_a Array
    end
  end

  shared_examples 'a successful query that returns one result' do
    it 'returns a single row' do
      expect(subject).to be
      expect(subject).to be_a Hash
    end
  end

  before do
    allow(Settings.edodb).to receive(:fake).and_return false
    allow(Settings.terms).to receive(:fake_now).and_return nil
    allow(Settings.terms).to receive(:use_term_definitions_json_file).and_return true
    allow(Settings.features).to receive(:hub_term_api).and_return false
  end

  it_behaves_like 'an Oracle driven data source' do
    subject { described_class }
  end

  it 'provides settings' do
    expect(EdoOracle::Queries.settings).to be Settings.edodb
  end

  it 'is configured correctly' do
    expect(described_class.settings).to be Settings.edodb
  end

  describe '#get_housing' do
    subject { described_class.get_housing(uid, aid_year) }
    let(:uid) { 61889 }
    let(:aid_year) { 2019 }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 2
      expect(subject[0]).to have_keys(%w(term_id term_descr housing_option housing_status housing_end_date acad_career))
      expect(subject[1]).to have_keys(%w(term_id term_descr housing_option housing_status housing_end_date acad_career))
    end
    it 'sorts the rows by term ID' do
      expect(subject[0]['term_id']).to eq '2188'
      expect(subject[1]['term_id']).to eq '2192'
    end
  end

  describe '#get_loan_history_status' do
    subject { described_class.get_loan_history_status(student_id) }
    let(:student_id) { 11667051 }

    it_behaves_like 'a successful query that returns one result'
  end

  describe '#enrolled_pre_fall_2016' do
    subject { described_class.enrolled_pre_fall_2016(student_id) }
    let(:student_id) { 11667051 }

    it_behaves_like 'a successful query that returns one result'
  end

  describe '#get_loan_history_categories_cumulative' do
    subject { described_class.get_loan_history_categories_cumulative }

    it_behaves_like 'a successful query'
  end

  describe '#get_loan_history_cumulative_loan_amount' do
    subject { described_class.get_loan_history_cumulative_loan_amount(student_id, view_name) }
    let(:student_id) { 11667051 }
    let(:view_name) { 'CLC_FA_LNHST_DTL_AY_GRADPLUS' }

    it_behaves_like 'a successful query that returns one result'
  end

  describe '#get_loan_history_categories_aid_years' do
    subject { described_class.get_loan_history_categories_aid_years(student_id) }
    let(:student_id) { 11667051 }

    it_behaves_like 'a successful query'
  end

  describe '#get_loan_history_aid_years_details' do
    subject { described_class.get_loan_history_aid_years_details(student_id, view_name) }
    let(:student_id) { 11667051 }
    let(:view_name) { 'CLC_FA_LNHST_DTL_AY_GRADPLUS' }

    it_behaves_like 'a successful query'
  end

  describe '#get_loan_history_resources' do
    subject { described_class.get_loan_history_resources }

    it_behaves_like 'a successful query'
  end

  describe '#get_loan_history_glossary_cumulative' do
    subject { described_class.get_loan_history_glossary_cumulative }

    it_behaves_like 'a successful query'
  end

  describe '#get_loan_history_glossary_aid_years' do
    subject { described_class.get_loan_history_glossary_aid_years }

    it_behaves_like 'a successful query'
  end

  describe '#get_loan_history_messages' do
    subject { described_class.get_loan_history_messages }

    it_behaves_like 'a successful query'
  end

  describe '#get_financial_aid_scholarships_summary' do
    subject { described_class.get_financial_aid_summary(uid, aid_year) }
    let(:uid) { 61889 }
    let(:aid_year) { 2018 }

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject).to have_keys(%w(student_id uc_cost_attendance uc_gift_aid_waiver uc_net_cost uc_funding_offered uc_gift_aid_out uc_grants_schol uc_waivers_oth uc_fee_waivers uc_loans_wrk_study uc_loans uc_work_study sfa_ss_group))
    end
  end

  describe '#get_aid_years' do
    subject { described_class.get_aid_years(uid) }
    let(:uid) { 61889 }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 2
      expect(subject[0]).to have_keys(%w(aid_year aid_year_descr default_aid_year aid_received_fall aid_received_spring aid_received_summer))
      expect(subject[1]).to have_keys(%w(aid_year aid_year_descr default_aid_year aid_received_fall aid_received_spring aid_received_summer))
    end

    it 'sorts the rows by aid year' do
      expect(subject[0]['aid_year']).to eq '2018'
      expect(subject[1]['aid_year']).to eq '2019'
    end
  end

  describe '#get_title4' do
    subject { described_class.get_title4(uid) }
    let(:uid) { 61889 }

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject.count).to eq 8
      expect(subject).to have_keys(%w(approved response_descr main_header main_body dynamic_header dynamic_body dynamic_label contact_text))
    end
  end

  describe '#get_terms_and_conditions' do
    subject { described_class.get_terms_and_conditions(uid, aid_year) }
    let(:uid) { 61889 }
    let(:aid_year) { 2018 }

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject.count).to eq 7
      expect(subject).to have_keys(%w(aid_year approved response_descr main_header main_body dynamic_header dynamic_body))
    end
  end

end
