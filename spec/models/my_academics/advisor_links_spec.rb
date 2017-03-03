describe MyAcademics::AdvisorLinks do
  let(:uid) { random_id }
  let(:user_cs_id) { random_id }

  before do
    allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: uid).and_return(
      double(lookup_campus_solutions_id: user_cs_id)
    )
  end

  subject do
    {}.tap {|x| MyAcademics::AdvisorLinks.new(uid).merge(x)}
  end

  it 'merges student links into feed' do
    expect(subject[:advisorLinks]).to be
    expect(subject[:advisorLinks][:tcReportLink]).to be
    expect(subject[:advisorLinks][:tcReportLink][:name]).to eq 'Transfer Credit Report'
    expect(subject[:advisorLinks][:tcReportLink][:url]).to eq "https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/SSR_ADVISEE_OVRD.CSU_DA_TRN_CDT.GBL?EMPLID=#{user_cs_id}"
  end
end
