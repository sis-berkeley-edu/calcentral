require 'spec_helper'

describe MyCommittees::FacultyCommittees do
  let(:feed) { described_class.new(uid).get_feed }

  let(:uid) { random_id }
  let(:fake_faculty_committees_proxy) { CampusSolutions::FacultyCommittees.new(fake: true) }

  context 'fake data' do
    before do
      allow(CampusSolutions::FacultyCommittees).to receive(:new).and_return fake_faculty_committees_proxy
    end
    it 'contains the expected faculty data' do
      committees = feed[:facultyCommittees][:active]
      expect(committees[0][:committeeType]).to eq 'Advancement to Candidacy Mas1'
      expect(committees[0][:program]).to eq 'Civil Environmental Eng MS'
      expect(committees[0][:statusMessage]).to eq 'Pending'
      expect(committees[0][:serviceRange]).to eq 'Aug 30, 2016 - Aug 30, 2017'
    end

    it 'contains the expected faculty committee data' do
      members = feed[:facultyCommittees][:active][0][:committeeMembers]
      expect(members[:additionalReps][0][:name]).to eq 'John Bear'
      expect(members[:additionalReps][0][:primaryDepartment]).to eq 'Civil Environmental Eng'
    end
  end
end
