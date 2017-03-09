require 'spec_helper'

describe MyCommittees::FacultyCommittees do
  let(:feed) { described_class.new(uid).get_feed }
  let(:uid) { random_id }
  let(:user_cs_id) { random_id }
  let(:fake_faculty_committees_proxy) { CampusSolutions::FacultyCommittees.new(fake: true, user_id: uid) }

  context 'fake data' do
    before do
      allow(CampusSolutions::FacultyCommittees).to receive(:new).and_return fake_faculty_committees_proxy
      allow(DateTime).to receive(:now).and_return DateTime.parse('2016-11-04')
      allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: uid).and_return(
        double(lookup_campus_solutions_id: user_cs_id))
    end

    it 'dumps all committees into one list' do
      expect(feed[:facultyCommittees].count).to eq 4
    end

    it 'sorts the committees by the current user\'s membership end date and start date' do
      committees = feed[:facultyCommittees]
      expect(committees[0][:csMemberStartDate]).to be nil
      expect(committees[0][:csMemberEndDate]).to be nil
      expect(committees[1][:csMemberStartDate]).to eq '2016-08-31'
      expect(committees[1][:csMemberEndDate]).to eq '2999-01-01'
      expect(committees[2][:csMemberStartDate]).to eq '2016-08-30'
      expect(committees[2][:csMemberEndDate]).to eq '2017-08-30'
      expect(committees[3][:csMemberStartDate]).to eq '2015-08-31'
      expect(committees[3][:csMemberEndDate]).to eq '2016-01-01'
    end

    it 'correctly parses a committee with no members' do
      committee = feed[:facultyCommittees][0]
      expect(committee[:serviceRange]).to be nil
    end

    it 'correctly parses a Dissertation committee' do
      committee = feed[:facultyCommittees][1]
      expect(committee[:committeeType]).to eq 'Dissertation Committee'
      expect(committee[:program]).to eq 'Education PhD'
      expect(committee[:statusTitle]).to eq nil
      expect(committee[:statusMessage]).to eq 'Advanced: Oct 06, 2017'
      expect(committee[:statusIcon]).to eq nil
      expect(committee[:serviceRange]).to eq 'Aug 31, 2016 - Present'
    end

    it 'correctly parses a Qualifying Exam committee' do
      committee = feed[:facultyCommittees][2]
      expect(committee[:committeeType]).to eq 'Qualifying Exam Committee'
      expect(committee[:program]).to eq 'Civil Environmental Eng MS'
      expect(committee[:statusTitle]).to eq nil
      expect(committee[:statusMessage]).to eq nil
      expect(committee[:statusIcon]).to eq 'check'
      expect(committee[:serviceRange]).to eq 'Aug 30, 2016 - Aug 30, 2017'
    end

    it 'correctly parses a Masters Thesis committee' do
      committee = feed[:facultyCommittees][3]
      expect(committee[:committeeType]).to eq 'Master\'s Thesis Committee'
      expect(committee[:program]).to eq 'South & SE Asian Studies MA'
      expect(committee[:statusTitle]).to eq nil
      expect(committee[:statusMessage]).to eq 'Filing Date: Nov 06, 2016'
      expect(committee[:statusIcon]).to eq 'check'
      expect(committee[:serviceRange]).to eq 'Aug 31, 2015 - Jan 01, 2016'
    end

    it 'contains the expected milestone attempts data ordered with most recent first' do
      qualifying_exam_attempts = feed[:facultyCommittees][2][:milestoneAttempts]
      expect(qualifying_exam_attempts.count).to eq 3
      expect(qualifying_exam_attempts[0][:sequenceNumber]).to eq 3
      expect(qualifying_exam_attempts[0][:date]).to eq 'Jan 01, 2015'
      expect(qualifying_exam_attempts[0][:result]).to eq 'Passed'
      expect(qualifying_exam_attempts[1][:sequenceNumber]).to eq 2
      expect(qualifying_exam_attempts[1][:date]).to eq 'Jan 01, 2014'
      expect(qualifying_exam_attempts[1][:result]).to eq 'Partially Failed'
      expect(qualifying_exam_attempts[2][:sequenceNumber]).to eq 1
      expect(qualifying_exam_attempts[2][:date]).to eq 'Jan 01, 2013'
      expect(qualifying_exam_attempts[2][:result]).to eq 'Failed'
    end

    it 'builds a string to represent the milestone attempt' do
      qualifying_exam_attempts = feed[:facultyCommittees][2][:milestoneAttempts]
      expect(qualifying_exam_attempts[0][:display]).to eq 'Exam 3: Passed Jan 01, 2015'
      expect(qualifying_exam_attempts[1][:display]).to eq 'Exam 2: Partially Failed Jan 01, 2014'
      expect(qualifying_exam_attempts[2][:display]).to eq 'Exam 1: Failed Jan 01, 2013'
    end

    it 'contains the expected faculty committee data' do
      members = feed[:facultyCommittees][2][:committeeMembers]
      expect(members[:additionalReps][0][:name]).to eq 'John Bear'
      expect(members[:additionalReps][1][:name]).to eq 'Bad Dog'
    end

    it 'replaces bogus dates with text' do
      committee = feed[:facultyCommittees][1]
      expect(committee[:serviceRange]).to eq 'Aug 31, 2016 - Present'
    end
  end
end
