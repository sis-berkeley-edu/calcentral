describe FinancialAid::MyAwards do
  let(:uid) { 61889 }
  let(:aid_year) { 2020 }

  let(:berkeley_grant_award_record) do
    {
      'item_type' => '942102900000',
      'title' => 'Berkeley Grant',
      'subtitle' => nil,
      'award_type' => 'giftaid',
      'left_col_val' => 'Accepted',
      'left_col_amt' => BigDecimal.new("15929.0"),
      'right_col_val' => 'Not Disbursed',
      'right_col_amt' => BigDecimal.new("0.0"),
      'award_message' => nil
    }
  end

  let(:federal_pell_grant_record) do
    {
      'item_type' => '946200100000',
      'title' => 'Federal Pell Grant',
      'subtitle' => nil,
      'award_type' => 'giftaid',
      'left_col_val' => 'Accepted',
      'left_col_amt' => BigDecimal.new("6195.0"),
      'right_col_val' => 'Not Disbursed',
      'right_col_amt' => BigDecimal.new("0.0"),
      'award_message' => nil
    }
  end

  let(:federal_seog_grant_record) do
    {
      'item_type' => '946200300000',
      'title' => 'Federal SEOG Grant',
      'subtitle' => nil,
      'award_type' => 'giftaid',
      'left_col_val' => 'Accepted',
      'left_col_amt' => BigDecimal.new("400.0"),
      'right_col_val' => 'Not Disbursed',
      'right_col_amt' => BigDecimal.new("0.0"),
      'award_message' => nil
    }
  end

  let(:federal_subsidized_loan_1_record) do
    {
      'item_type' => '961100100000',
      'title' => 'Federal Subsidized Loan 1',
      'subtitle' => nil,
      'award_type' => 'subsidizedloans',
      'left_col_val' => 'Accepted',
      'left_col_amt' => BigDecimal.new("2750.0"),
      'right_col_val' => 'Not Disbursed',
      'right_col_amt' => BigDecimal.new("0.0"),
      'award_message' => nil
    }
  end

  let(:federal_subsidized_loan_2_record) do
    {
      'item_type' => '961100200000',
      'title' => 'Federal Subsidized Loan 2',
      'subtitle' => nil,
      'award_type' => 'subsidizedloans',
      'left_col_val' => 'Offered',
      'left_col_amt' => BigDecimal.new("2750.0"),
      'right_col_val' => 'Not Disbursed',
      'right_col_amt' => BigDecimal.new("0.0"),
      'award_message' => nil
    }
  end

  let(:fws_undergrad_eligibility_record) do
    {
      'item_type' => '951100100000',
      'title' => 'FWS Undergraduate Eligibility',
      'subtitle' => nil,
      'award_type' => 'workstudy',
      'left_col_val' => 'Accepted',
      'left_col_amt' => BigDecimal.new("4000.0"),
      'right_col_val' => 'No Earnings',
      'right_col_amt' => BigDecimal.new("0.0"),
      'award_message' => nil
    }
  end

  let(:award_records) do
    [
      berkeley_grant_award_record,
      federal_pell_grant_record,
      federal_seog_grant_record,
      federal_subsidized_loan_1_record,
      federal_subsidized_loan_2_record,
      fws_undergrad_eligibility_record
    ]
  end

  # let(:award_type_total_giftaid) { [ {'total' => BigDecimal.new("22524.0") } ] }
  let(:award_type_total) { [ {'total' => BigDecimal.new("22524.0") } ] }

  let(:awards_total) { [{ 'total' => BigDecimal.new("32024.0") }] }

  before do
    allow_any_instance_of(FinancialAid::MyAidYears).to receive(:default_aid_year).and_return '2020'
    allow(EdoOracle::FinancialAid::Queries).to receive(:get_awards).and_return(award_records)
    allow(EdoOracle::FinancialAid::Queries).to receive(:get_awards_total_by_type).and_return(award_type_total)
    allow(EdoOracle::FinancialAid::Queries).to receive(:get_awards_total).and_return(awards_total)
  end

  describe '#get_feed' do
    subject { described_class.new(uid, {aid_year: aid_year}).get_feed }

    it_behaves_like 'a proxy that properly observes the financial_aid feature flag'

    it 'returns the expected result' do
      expect(subject).to be
      expect(subject[:awards]).to be
      expect(subject[:awards].count).to eq 10
      expect(subject[:messages]).to be
      expect(subject[:messages][:messageInfo]).to be
      expect(subject[:messages][:messageEstDisbursements]).to be
      expect(subject[:errored]).to be_falsey
    end
  end
end
