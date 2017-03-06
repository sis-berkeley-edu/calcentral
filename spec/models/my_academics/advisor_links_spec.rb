describe MyAcademics::AdvisorLinks do
  let(:uid) { random_id }
  let(:user_cs_id) { random_id }
  let(:tcReportLink) do
    {
      link: {
        name: 'Transfer Credit Report',
        url: "https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/SSR_ADVISEE_OVRD.CSU_DA_TRN_CDT.GBL?EMPLID=#{user_cs_id}"
      }
    }
  end
  let(:updatePlanUrl) do
    {
      link: {
        name: 'Update Multi-Year Planner',
        url: "https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/SCI_PLNR_ADMIN.SCI_PLNR_FL.GBL?&EMPLID=#{user_cs_id}"
      }
    }
  end

  before do
    crosswalk_double = double(lookup_campus_solutions_id: user_cs_id)
    allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: uid).and_return(crosswalk_double)

    # stub CS Link proxy responses
    fake_cs_link_proxy = double
    allow(fake_cs_link_proxy).to receive(:get_url).with('UC_CX_XFER_CREDIT_REPORT_ADVSR', {:EMPLID => user_cs_id}).and_return(tcReportLink)
    allow(fake_cs_link_proxy).to receive(:get_url).with('UC_CX_PLANNER_ADV_STDNT', {:EMPLID => user_cs_id}).and_return(updatePlanUrl)
    allow(CampusSolutions::Link).to receive(:new).and_return(fake_cs_link_proxy)
  end

  subject do
    {}.tap {|x| MyAcademics::AdvisorLinks.new(uid).merge(x)}
  end

  it 'merges student links into feed' do
    expect(subject[:advisorLinks]).to be
    expect(subject[:advisorLinks][:tcReportLink]).to be
    expect(subject[:advisorLinks][:tcReportLink][:name]).to eq 'Transfer Credit Report'
    expect(subject[:advisorLinks][:tcReportLink][:url]).to eq "https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/SSR_ADVISEE_OVRD.CSU_DA_TRN_CDT.GBL?EMPLID=#{user_cs_id}"
    expect(subject[:advisorLinks][:updatePlanUrl]).to be
    expect(subject[:advisorLinks][:updatePlanUrl][:name]).to eq 'Update Multi-Year Planner'
    expect(subject[:advisorLinks][:updatePlanUrl][:url]).to eq "https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/SCI_PLNR_ADMIN.SCI_PLNR_FL.GBL?&EMPLID=#{user_cs_id}"
  end
end
