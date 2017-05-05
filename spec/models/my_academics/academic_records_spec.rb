describe MyAcademics::AcademicRecords do
  let(:uid) { random_id }
  let(:emplid) { random_id }
  let(:feed) { subject.get_feed }
  let(:roles) { {'fpf' => false } }
  subject { MyAcademics::AcademicRecords.new(uid) }

  before do
    allow(CalnetCrosswalk::ByUid).to receive(:new).and_return(double(lookup_campus_solutions_id: emplid))
    allow(HubEdos::MyAcademicStatus).to receive(:get_roles).and_return(roles)
  end

  context 'when providing feed' do
    context 'credential solutions url and post parameters' do
      it 'includes credential solutions post url' do
        expect(feed[:officialTranscriptRequestData]).to be
        expect(feed[:officialTranscriptRequestData][:postUrl]).to eq 'https://www.credentials-inc.com/CGI-BIN/dvcgitp.pgm'
      end
      it 'includes credential solutions post parameters' do
        expect(feed[:officialTranscriptRequestData]).to be
        expect(feed[:officialTranscriptRequestData][:postParams][:studid]).to be
        expect(feed[:officialTranscriptRequestData][:postParams][:emplid]).to be
        expect(feed[:officialTranscriptRequestData][:postParams][:email]).to be
        expect(feed[:officialTranscriptRequestData][:postParams][:cntry]).to be
        expect(feed[:officialTranscriptRequestData][:postParams][:city]).to be
        expect(feed[:officialTranscriptRequestData][:postParams][:tel25]).to be
      end
      it 'credential solutions post parameters do not include link or debug values' do
        expect(feed[:officialTranscriptRequestData][:postParams][:credSolLink]).to_not be
        expect(feed[:officialTranscriptRequestData][:postParams][:debugDbname]).to_not be
        expect(feed[:officialTranscriptRequestData][:postParams][:debugJavaString1]).to_not be
        expect(feed[:officialTranscriptRequestData][:postParams][:debugJavaString2]).to_not be
      end
    end

    context 'unofficial law transcript link' do
      it 'includes unofficial law transcript link' do
        expect(feed[:lawUnofficialTranscriptLink][:name]).to eq 'Transcript (Unofficial) - Law School Students'
        expect(feed[:lawUnofficialTranscriptLink][:title]).to eq 'Request your Law Unofficial Transcript'
        expect(feed[:lawUnofficialTranscriptLink][:url]).to eq "https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.SSS_TSRQST_UNOFF.GBL?EMPLID=#{emplid}"
        expect(feed[:lawUnofficialTranscriptLink][:ucFrom]).to be
        expect(feed[:lawUnofficialTranscriptLink][:ucFromLink]).to be
        expect(feed[:lawUnofficialTranscriptLink][:ucFromText]).to be
      end
    end

    context 'academic roles' do
      it 'includes academic roles' do
        expect(feed[:academicRoles]['fpf']).to eq false
      end
    end
  end
end
