describe MyAcademics::StudentLinks do
  let(:uid) { random_id }
  let(:user_cs_id) { random_id }
  let(:fake) { true }

  subject do
    {}.tap {|x| MyAcademics::StudentLinks.new(uid).merge(x)}
  end

  it 'merges student links into feed' do
    expect(subject[:studentLinks]).to be
    expect(subject[:studentLinks][:tcReportLink]).to be
    expect(subject[:studentLinks][:tcReportLink][:name]).to eq 'Transfer Credit Report'
    expect(subject[:studentLinks][:tcReportLink][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/CSU_DA_TRN_CDT_STD.CSU_DA_TRN_CDT_STD.GBL'
  end
end
