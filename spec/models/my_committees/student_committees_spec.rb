require 'spec_helper'

describe MyCommittees::StudentCommittees do
  let(:feed) { described_class.new(uid).get_feed }
  let(:uid) { random_id }
  let(:user_cs_id) { random_id }
  let(:fake_student_committees_proxy) { CampusSolutions::StudentCommittees.new(fake: true, user_id: uid) }

  context 'fake data' do
    before do
      allow(CampusSolutions::StudentCommittees).to receive(:new).and_return fake_student_committees_proxy
      allow(DateTime).to receive(:now).and_return DateTime.parse('2016-11-04')
      allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: uid).and_return(
        double(lookup_campus_solutions_id: user_cs_id))
    end

    it 'correctly parses a qualifying exam committee when student has passed the exam' do
      committee = feed[:studentCommittees][0]
      expect(committee[:committeeType]).to eq 'COMMITTEEDESCRLONG1'
      expect(committee[:program]).to eq 'STUDENTACADPLAN1'
      expect(committee[:statusIcon]).to eq 'check'
      expect(committee[:statusMessage]).to eq nil
    end

    it 'contains the expected student data for a completed committee' do
      committee = feed[:studentCommittees][1]
      expect(committee[:committeeType]).to eq 'NOT ACTIVE'
    end

    it 'correctly parses a qualifying exam committee when student has failed the exam' do
      committee = feed[:studentCommittees][2]
      expect(committee[:committeeType]).to eq 'Qualifying Exam Committee'
      expect(committee[:program]).to eq 'STUDENTACADPLAN3'
      expect(committee[:statusIcon]).to eq 'exclamation-triangle'
      expect(committee[:statusMessage]).to be nil
    end

    it 'contains the expected student data for a dissertation committee' do
      committee = feed[:studentCommittees][3]
      expect(committee[:committeeType]).to eq 'Dissertation Committee'
      expect(committee[:program]).to eq 'STUDENTACADPLAN4'
      expect(committee[:statusIcon]).to eq 'check'
      expect(committee[:statusMessage]).to eq 'Filing Date: Jun 16, 2025'
    end

    it 'contains the expected student data for a Masters Thesis committee' do
      committee = feed[:studentCommittees][5]
      expect(committee[:committeeType]).to eq 'Master\'s Thesis Committee'
      expect(committee[:program]).to eq 'STUDENTACADPLAN6'
      expect(committee[:statusIcon]).to eq nil
      expect(committee[:statusMessage]).to eq 'Advanced: Jun 16, 2018'
    end

    it 'contains only the most recent milestone attempt' do
      qualifying_exam_attempts = feed[:studentCommittees][0][:milestoneAttempts]
      expect(qualifying_exam_attempts.count).to eq 1
      expect(qualifying_exam_attempts[0][:sequenceNumber]).to eq 2
      expect(qualifying_exam_attempts[0][:date]).to eq 'Jan 01, 2015'
      expect(qualifying_exam_attempts[0][:result]).to eq 'Passed'
    end

    context 'when building a string to represent the milestone attempt' do
      it 'includes the attempt number if student did not pass the first attempt' do
        qualifying_exam_attempts = feed[:studentCommittees][2][:milestoneAttempts]
        expect(qualifying_exam_attempts[0][:display]).to eq 'Exam 1: Failed Jan 01, 2014'
      end
      it 'does not include the attempt number if student passed the first attempt' do
        qualifying_exam_attempts = feed[:studentCommittees][4][:milestoneAttempts]
        expect(qualifying_exam_attempts[0][:display]).to eq 'Passed Jan 01, 2016'
      end
    end

    it 'filters out committee members with end date in the past' do
      members = feed[:studentCommittees][0][:committeeMembers]
      expect(members[:chair].count).to eq 2
    end

    it 'contains the expected student committee data for chairs' do
      members = feed[:studentCommittees][0][:committeeMembers]
      expect(members[:chair][0][:name]).to eq 'MEMBERFIRSTNAME1 MEMBERLASTNAME1'
      expect(members[:chair][0][:email]).to eq 'MEMBER@EMAIL.1'
      expect(members[:chair][0][:primaryDepartment]).to eq 'MEMBERDEPTDESCR1'

      expect(members[:chair][1][:name]).to eq 'MEMBERFIRSTNAME2 MEMBERLASTNAME2'
      expect(members[:chair][1][:email]).to eq 'MEMBER@EMAIL.2'
      expect(members[:chair][1][:primaryDepartment]).to eq 'MEMBERDEPTDESCR2'
    end

    it 'contains the expected student committee data for co-chairs' do
      members = feed[:studentCommittees][0][:committeeMembers]
      expect(members[:coChair][0][:name]).to eq 'MEMBERFIRSTNAME3 MEMBERLASTNAME3'
      expect(members[:coChair][0][:email]).to eq 'MEMBER@EMAIL.3'
      expect(members[:coChair][0][:primaryDepartment]).to eq 'MEMBERDEPTDESCR3'

      expect(members[:coChair][1][:name]).to eq 'MEMBERFIRSTNAME4 MEMBERLASTNAME4'
      expect(members[:coChair][1][:email]).to eq 'MEMBER@EMAIL.4'
      expect(members[:coChair][1][:primaryDepartment]).to eq 'MEMBERDEPTDESCR4'
    end

    it 'contains the expected student committee data for additional reps' do
      members = feed[:studentCommittees][0][:committeeMembers]
      expect(members[:additionalReps][0][:name]).to eq 'MEMBERFIRSTNAME5 MEMBERLASTNAME5'
      expect(members[:additionalReps][0][:email]).to eq 'MEMBER@EMAIL.5'
      expect(members[:additionalReps][0][:primaryDepartment]).to eq 'MEMBERDEPTDESCR5'

      expect(members[:additionalReps][1][:name]).to eq 'MEMBERFIRSTNAME6 MEMBERLASTNAME6'
      expect(members[:additionalReps][1][:email]).to eq 'MEMBER@EMAIL.6'
      expect(members[:additionalReps][1][:primaryDepartment]).to eq 'MEMBERDEPTDESCR6'
    end

    it 'contains the expected student committee data for academic senate' do
      members = feed[:studentCommittees][0][:committeeMembers]
      expect(members[:academicSenate][0][:name]).to eq 'MEMBERFIRSTNAME7 MEMBERLASTNAME7'
      expect(members[:academicSenate][0][:email]).to eq 'MEMBER@EMAIL.7'
      expect(members[:academicSenate][0][:primaryDepartment]).to eq 'MEMBERDEPTDESCR7'
    end
  end

  describe '#inactive?' do
    let(:committee_member) do
      {
        :memberEndDate => end_date
      }
    end
    let(:result) { described_class.new(uid).inactive?(committee_member) }

    context 'valid future date' do
      let(:end_date) { '2999-01-01' }
      it 'parses date and flags member as active' do
        expect(result).to be false
      end
    end

    context 'valid past date' do
      let(:end_date) { '1999-01-01' }
      it 'parses date and flags member as inactive' do
        expect(result).to be true
      end
    end

    context 'invalid date' do
      let(:end_date) { 'bogus' }
      it 'fails the date parsing but assumes member is active' do
        expect(result).to be false
      end
    end
  end
end
