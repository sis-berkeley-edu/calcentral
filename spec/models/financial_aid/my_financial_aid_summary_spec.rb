describe FinancialAid::MyFinancialAidSummary do
  before do
    allow_any_instance_of(FinancialAid::MyAidYears).to receive(:get_feed).and_return aid_years
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_CX_FA_SHOPPING_SHEET', {EMPLID: cs_id, AID_YEAR: '2017', ACAD_CAREER: 'UGRD', INSTITUTION: 'UCB01', SFA_SS_GROUP: 'CCUGRD'}).and_return('2017 shopping sheet link')
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_CX_FA_SHOPPING_SHEET', {EMPLID: cs_id,AID_YEAR: '2018', ACAD_CAREER: 'UGRD', INSTITUTION: 'UCB01', SFA_SS_GROUP: 'CCUGRD'}).and_return('2018 shopping sheet link')
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_CX_FA_UCB_FA_WEBSITE').and_return('financial_aid website link')
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_FA_FINRES_FA_SUMMARY').and_return('financial_aid summary link')
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_CX_CAL_STUDENT_CENTRAL').and_return('cal student central link')
    allow(EdoOracle::FinancialAid::Queries).to receive(:get_financial_aid_summary).and_return(financial_aid_summary)
  end

  let(:financial_aid_summary) do
    {
      "student_id"=>"84307640",
      "uc_cost_attendance" => BigDecimal.new("52093.0"),
      "uc_gift_aid_waiver" => BigDecimal.new("23942.0"),
      "uc_third_party" => BigDecimal.new("999.0"),
      "uc_net_cost" => BigDecimal.new("13019.0"),
      "uc_funding_offered" => BigDecimal.new("41902.0"),
      "uc_gift_aid_out" => BigDecimal.new("31112.0"),
      "uc_grants_schol" => BigDecimal.new("10989.0"),
      "uc_outside_resrces" => BigDecimal.new("99.0"),
      "uc_waivers_oth" => BigDecimal.new("3938.0"),
      "uc_fee_waivers" => BigDecimal.new("87.0"),
      "uc_loans_wrk_study" => BigDecimal.new("31782.0"),
      "uc_loans" => BigDecimal.new("8787.0"),
      "uc_work_study" => BigDecimal.new("1231.0"),
      "sfa_ss_group" => nil,
    }
  end

  let(:aid_years) do
    {
      aidYears: [
        {
          id: '2017',
          defaultAidYear: true
        },
        {
          id: '2018',
          defaultAidYear: false
        },
      ]
    }
  end

  describe '#get_feed' do
    subject { described_class.new(uid).get_feed }
    let(:uid) { 61889 }
    let(:cs_id) { '11667051' }

    it_behaves_like 'a proxy that properly observes the financial_aid feature flag'

    it 'returns the summary for each aid year' do
      expect(subject).to be
      expect(subject[:financialAidSummary]).to be
      expect(subject[:financialAidSummary][:aidYears]).to be
      expect(subject[:financialAidSummary][:aidYears].count).to eq 2
      expect(subject[:financialAidSummary][:aid]).to be

      expect(subject[:financialAidSummary][:aid]['2017']).to be
      expect(subject[:financialAidSummary][:aid]['2017'][:totalCostOfAttendance]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:totalGiftAidAndWaivers]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:totalNetCost]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:totalFundingOffered]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:giftAidAndOutsideResources]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:grantsAndScholarships]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:waiversAndOtherFunding]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:feeWaivers]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:loansAndWorkStudy]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:loans]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:workStudy]).to be_a Float

      expect(subject[:financialAidSummary][:aid]['2018']).to be
      expect(subject[:financialAidSummary][:aid]['2018'][:totalCostOfAttendance]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:totalGiftAidAndWaivers]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:totalNetCost]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:totalFundingOffered]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:giftAidAndOutsideResources]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:grantsAndScholarships]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:waiversAndOtherFunding]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:feeWaivers]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:loansAndWorkStudy]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:loans]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:workStudy]).to be_a Float
    end
    it 'provides the expected links' do
      expect(subject[:financialAidSummary][:links]).to be
      expect(subject[:financialAidSummary][:links].count).to eq 2
      expect(subject[:financialAidSummary][:links][:financialAidWebsite]).to eq 'financial_aid website link'
      expect(subject[:financialAidSummary][:links][:calStudentCentral]).to eq 'cal student central link'
    end
    it 'does not provide a link to the Shopping Sheet' do
      expect(subject[:financialAidSummary][:aid]['2017'][:shoppingSheetLink]).not_to be
      expect(subject[:financialAidSummary][:aid]['2018'][:shoppingSheetLink]).not_to be
    end

    context 'when user is assigned to the \'CCUGRD\' group for one aid year' do
      let(:financial_aid_summary) do
        {
          "student_id"=>"84307640",
          "uc_cost_attendance" => BigDecimal.new("39389.0"),
          "uc_gift_aid_waiver" => BigDecimal.new("38398.0"),
          "uc_third_party" => BigDecimal.new("999.0"),
          "uc_net_cost" => BigDecimal.new("7878.0"),
          "uc_funding_offered" => BigDecimal.new("49218.0"),
          "uc_gift_aid_out" => BigDecimal.new("28272.0"),
          "uc_grants_schol" => BigDecimal.new("38378.0"),
          "uc_outside_resrces" => BigDecimal.new("99.0"),
          "uc_waivers_oth" => BigDecimal.new("0.0"),
          "uc_fee_waivers" => BigDecimal.new("0.0"),
          "uc_loans_wrk_study" => BigDecimal.new("5898.0"),
          "uc_loans" => BigDecimal.new("3839.0"),
          "uc_work_study" => BigDecimal.new("2635.0"),
          "sfa_ss_group" => "CCUGRD",
        }
      end

      let(:uid) { 799934 }
      let(:cs_id) { '84307640' }

      it 'provides a link to the Shopping Sheet for that aid year' do
        expect(subject[:financialAidSummary][:aid]['2017'][:shoppingSheetLink]).to eq '2017 shopping sheet link'
        expect(subject[:financialAidSummary][:aid]['2018'][:shoppingSheetLink]).to eq '2018 shopping sheet link'
      end
    end
  end
end
