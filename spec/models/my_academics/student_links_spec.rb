describe MyAcademics::StudentLinks do
  let(:uid) { random_id }
  let(:user_cs_id) { random_id }
  let(:tcReportLink) do
    {
      link: {
        name: 'Transfer Credit Report',
        url: 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/CSU_DA_TRN_CDT_STD.CSU_DA_TRN_CDT_STD.GBL'
      }
    }
  end
  let(:waitlistsAndStudentOptions) do
    {
      link: {
        name: 'Waitlists and Student Options',
        url: 'https://example.com/waitlists/student_options.html'
      }
    }
  end
  let(:academicGuideGradesPolicy) do
    {
      link: {
        name: 'Grading Policies',
        url: 'https://example.com/academic-policies/#gradestext',
      }
    }
  end


  before do
    # stub CS Link proxy responses
    fake_cs_link_proxy = double
    allow(fake_cs_link_proxy).to receive(:get_url).with('UC_CX_XFER_CREDIT_REPORT_STDNT').and_return(tcReportLink)
    allow(fake_cs_link_proxy).to receive(:get_url).with('UC_CX_WAITLIST_STDNT_OPTS').and_return(waitlistsAndStudentOptions)
    allow(fake_cs_link_proxy).to receive(:get_url).with('UC_CX_ACAD_GUIDE_GRADES').and_return(academicGuideGradesPolicy)
    allow(CampusSolutions::Link).to receive(:new).and_return(fake_cs_link_proxy)
  end

  subject do
    {}.tap {|x| MyAcademics::StudentLinks.new(uid).merge(x)}
  end

  it 'merges student links into feed' do
    expect(subject[:studentLinks]).to be
    expect(subject[:studentLinks][:tcReportLink]).to be
    expect(subject[:studentLinks][:tcReportLink][:name]).to eq 'Transfer Credit Report'
    expect(subject[:studentLinks][:tcReportLink][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/CSU_DA_TRN_CDT_STD.CSU_DA_TRN_CDT_STD.GBL'
    expect(subject[:studentLinks][:waitlistsAndStudentOptions]).to be
    expect(subject[:studentLinks][:waitlistsAndStudentOptions][:name]).to eq 'Waitlists and Student Options'
    expect(subject[:studentLinks][:waitlistsAndStudentOptions][:url]).to eq 'https://example.com/waitlists/student_options.html'
    expect(subject[:studentLinks][:academicGuideGradesPolicy]).to be
    expect(subject[:studentLinks][:academicGuideGradesPolicy][:name]).to eq 'Grading Policies'
    expect(subject[:studentLinks][:academicGuideGradesPolicy][:url]).to eq 'https://example.com/academic-policies/#gradestext'
  end
end
