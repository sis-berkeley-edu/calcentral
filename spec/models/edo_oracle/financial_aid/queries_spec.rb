describe EdoOracle::FinancialAid::Queries do
  let(:student_id) { 11667051 }
  let(:uid) { 61889 }
  let(:aid_year) { 2018 }
  let(:today) { Time.zone.today.in_time_zone.to_date }
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

    it_behaves_like 'a successful query that returns one result'
  end

  describe '#enrolled_pre_fall_2016' do
    subject { described_class.enrolled_pre_fall_2016(student_id) }

    it_behaves_like 'a successful query that returns one result'
  end

  describe '#get_loan_history_categories_cumulative' do
    subject { described_class.get_loan_history_categories_cumulative }

    it_behaves_like 'a successful query'
  end

  describe '#get_loan_history_cumulative_loan_amount' do
    subject { described_class.get_loan_history_cumulative_loan_amount(student_id, view_name) }

    let(:view_name) { 'CLC_FA_LNHST_DTL_AY_GRADPLUS' }

    it_behaves_like 'a successful query that returns one result'
  end

  describe '#get_loan_history_categories_aid_years' do
    subject { described_class.get_loan_history_categories_aid_years(student_id) }

    it_behaves_like 'a successful query'
  end

  describe '#get_loan_history_aid_years_details' do
    subject { described_class.get_loan_history_aid_years_details(student_id, view_name) }

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

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject).to have_keys(%w(student_id uc_cost_attendance uc_gift_aid_waiver uc_third_party uc_net_cost uc_funding_offered uc_gift_aid_out uc_grants_schol uc_outside_resrces uc_waivers_oth uc_fee_waivers uc_loans_wrk_study uc_loans uc_work_study sfa_ss_group))
    end
  end

  describe '#get_aid_years' do
    subject { described_class.get_aid_years(uid) }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 2
      expect(subject[0]).to have_keys(%w(aid_year aid_year_descr default_aid_year aid_received_fall aid_received_spring aid_received_summer))
      expect(subject[1]).to have_keys(%w(aid_year aid_year_descr default_aid_year aid_received_fall aid_received_spring aid_received_summer))
    end

    it 'sorts the rows by aid year' do
      expect(subject[0]['aid_year']).to eq '2019'
      expect(subject[1]['aid_year']).to eq '2018'
    end
  end

  describe '#get_title4' do
    subject { described_class.get_title4(uid) }

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject.count).to eq 8
      expect(subject).to have_keys(%w(approved response_descr main_header main_body dynamic_header dynamic_body dynamic_label contact_text))
    end
  end

  describe '#get_terms_and_conditions' do
    subject { described_class.get_terms_and_conditions(uid, aid_year) }

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject.count).to eq 7
      expect(subject).to have_keys(%w(aid_year approved response_descr main_header main_body dynamic_header dynamic_body))
    end
  end

  describe '#get_finaid_profile_status' do
    subject { described_class.get_finaid_profile_status(uid, aid_year, effective_date: today) }

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject.count).to eq 11
      expect(subject).to have_keys(%w(aid_year acad_career_descr exp_grad_term sap_status verification_status award_status candidacy filing_fee berkeley_pc title message))
    end
  end

  describe '#get_finaid_profile_acad_careers' do
    subject { described_class.get_finaid_profile_acad_careers(uid, aid_year, effective_date: today) }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 2
      expect(subject[0]).to have_keys(%w(aid_year term_id term_descr acad_career))
      expect(subject[1]).to have_keys(%w(aid_year term_id term_descr acad_career))
    end

    it 'sorts the rows by term' do
      expect(subject[0]['term_id']).to eq '2178'
      expect(subject[1]['term_id']).to eq '2182'
    end
  end

  describe '#get_finaid_profile_acad_level' do
    subject { described_class.get_finaid_profile_acad_level(uid, aid_year, effective_date: today) }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 3
      expect(subject[0]).to have_keys(%w(aid_year term_id term_descr acad_level))
      expect(subject[1]).to have_keys(%w(aid_year term_id term_descr acad_level))
      expect(subject[2]).to have_keys(%w(aid_year term_id term_descr acad_level))
    end

    it 'sorts the rows by term' do
      expect(subject[0]['term_id']).to eq '2178'
      expect(subject[1]['term_id']).to eq '2182'
      expect(subject[2]['term_id']).to eq '2185'
    end
  end

  describe '#get_finaid_profile_enrollment' do
    subject { described_class.get_finaid_profile_enrollment(uid, aid_year, effective_date: today) }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 3
      expect(subject[0]).to have_keys(%w(aid_year term_id term_descr term_units))
      expect(subject[1]).to have_keys(%w(aid_year term_id term_descr term_units))
      expect(subject[2]).to have_keys(%w(aid_year term_id term_descr term_units))
    end

    it 'sorts the rows by term' do
      expect(subject[0]['term_id']).to eq '2178'
      expect(subject[1]['term_id']).to eq '2182'
      expect(subject[2]['term_id']).to eq '2185'
    end
  end

  describe '#get_finaid_profile_SHIP' do
    subject { described_class.get_finaid_profile_SHIP(uid, aid_year, effective_date: today) }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 3
      expect(subject[0]).to have_keys(%w(aid_year term_id term_descr ship_status))
      expect(subject[1]).to have_keys(%w(aid_year term_id term_descr ship_status))
      expect(subject[2]).to have_keys(%w(aid_year term_id term_descr ship_status))
    end

    it 'sorts the rows by term' do
      expect(subject[0]['term_id']).to eq '2178'
      expect(subject[1]['term_id']).to eq '2182'
      expect(subject[2]['term_id']).to eq '2185'
    end
  end


  describe '#get_finaid_profile_isir' do
    subject { described_class.get_finaid_profile_isir(uid, aid_year, effective_date: today) }

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject.count).to eq 5
      expect(subject).to have_keys(%w(aid_year dependency_status primary_efc summer_efc family_in_college))
    end
  end

  describe '#get_awards' do
    subject { described_class.get_awards(uid, aid_year) }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query'

  end

  describe '#get_awards_total' do
    subject { described_class.get_awards_total(uid, aid_year) }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 1
      expect(subject[0]).to have_keys(%w(total))
    end
  end

  describe '#get_awards_disbursements' do
    subject { described_class.get_awards_disbursements(uid, aid_year, '951101500000') }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query'
  end

  describe '#get_awards_disbursements_tuition_fee_remission' do
    subject { described_class.get_awards_disbursements_tuition_fee_remission(uid, aid_year) }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query'
  end

  describe '#get_awards_alert_details' do
    subject { described_class.get_awards_alert_details(uid, aid_year, '951101500000') }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query'
  end

  describe '#get_awards_convert_wks_to_loan' do
    subject { described_class.get_awards_convert_wks_to_loan(uid, aid_year) }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query that returns one result'
  end

  describe '#get_awards_convert_loan_to_wks' do
    subject { described_class.get_awards_convert_loan_to_wks(uid, aid_year) }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query that returns one result'
  end

  describe '#get_awards_outside_resources' do
    subject { described_class.get_awards_outside_resources(aid_year) }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query that returns one result'
  end

  describe '#get_awards_reduce_cancel' do
    subject { described_class.get_awards_reduce_cancel(uid, aid_year) }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query that returns one result'
  end

  describe '#get_awards_accept_loans' do
    subject { described_class.get_awards_accept_loans(uid, aid_year, '961100200000') }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query that returns one result'
  end

  describe '#get_auth_failed_message' do
    subject { described_class.get_auth_failed_message(uid, aid_year, '946200300000') }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query that returns one result'
  end


  describe '#get_awards_by_term_types' do
    subject { described_class.get_awards_by_term_types(uid, aid_year) }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query'
  end

  describe '#get_awards_by_term_by_type' do
    subject { described_class.get_awards_by_term_by_type(uid, aid_year, 'giftaid') }

    let(:aid_year) { 2020 }

    it_behaves_like 'a successful query'
  end

  describe '#get_financial_resources_links' do
    subject { described_class.get_financial_resources_links() }

    it_behaves_like 'a successful query'
  end

end
