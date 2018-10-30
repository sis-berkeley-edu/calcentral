describe CampusSolutions::EnrollmentTerm do
  let(:user_id) { '12348' }
  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the enrollment card flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:enrollmentTerm]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::EnrollmentTerm.new(fake: true, user_id: user_id, term_id: '2176') }
    subject { proxy.get }
    it_should_behave_like 'a proxy that gets data'

    it 'returns specific mock data' do
      enrollment_feed = subject[:feed][:enrollmentTerm]
      expect(enrollment_feed[:studentId]).to eq '12701798'
      expect(enrollment_feed[:advisors][1][:name]).to eq 'Marsh Man'
      expect(enrollment_feed[:links][:scheduleClasses][:url]).to eq 'https://bcs-web-dev-03.is.berkeley.edu:8443/psc/bcsdev/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.CLASS_SEARCH.GBL?'
      expect(enrollment_feed[:enrollmentPeriod][0][:id]).to eq 'phase1'
      expect(enrollment_feed[:enrolledClasses][0][:id]).to eq '12081'
      expect(enrollment_feed[:waitlistedClasses][0][:id]).to eq '15636'
    end

    it 'formats dates' do
      expect(subject[:feed][:enrollmentTerm][:enrollmentPeriod][0][:date]).to include(
        epoch: 1461019200,
        datestring: '4/18'
      )
    end

    it 'provides a list of class meeting times' do
      expect(subject[:feed][:enrollmentTerm][:enrolledClasses][0][:when]).to be_a Array
      expect(subject[:feed][:enrollmentTerm][:enrolledClasses][0][:when][0]).to eq 'M 11:30A-12:59P'
      expect(subject[:feed][:enrollmentTerm][:enrolledClasses][0][:when][1]).to eq 'M 4:00P-5:29P'

      expect(subject[:feed][:enrollmentTerm][:waitlistedClasses][0][:when]).to be_a Array
      expect(subject[:feed][:enrollmentTerm][:waitlistedClasses][0][:when][0]).to eq 'Monday  Wednesday 10:00 AM-10:59 AM'
    end

    it 'forces year to the end of the term description' do
      expect(subject[:feed][:enrollmentTerm][:termDescr]).to eq 'Spring 2016'
    end
  end
end
