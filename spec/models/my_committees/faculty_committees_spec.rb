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

    it 'sorts active and inactive committees into separate lists' do
      expect(feed[:facultyCommittees][:active].count).to eq 1
      expect(feed[:facultyCommittees][:completed].count).to eq 1
    end
    it 'contains the expected faculty data' do
      committees = feed[:facultyCommittees][:active]
      expect(committees[0][:committeeType]).to eq 'Qualifying Exam Committee'
      expect(committees[0][:program]).to eq 'Civil Environmental Eng MS'
      expect(committees[0][:statusTitle]).to eq 'Proposed Exam Date:'
      expect(committees[0][:statusMessage]).to eq 'Pending'
      expect(committees[0][:serviceRange]).to eq 'Aug 30, 2016 - Aug 30, 2017'
    end

    it 'contains the expected faculty committee data' do
      members = feed[:facultyCommittees][:active][0][:committeeMembers]
      expect(members[:additionalReps][0][:name]).to eq 'John Bear'
      expect(members[:additionalReps][1][:name]).to eq 'Bad Dog'
    end

    it 'replaces bogus dates with text' do
      committees = feed[:facultyCommittees][:completed]
      expect(committees[0][:serviceRange]).to eq 'Aug 30, 2016 - Present'
    end
  end
end
