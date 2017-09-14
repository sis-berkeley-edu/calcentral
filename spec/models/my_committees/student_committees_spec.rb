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

    context 'when committee is active' do
      let(:committee) { feed[:studentCommittees][2] }

      it 'correctly identifies an active committee' do
        committee = feed[:studentCommittees][2]
        expect(committee[:isActive]).to be true
      end
      it 'includes both active members and members who have completed service' do
        expect(committee[:committeeMembers][:chair].count).to eq 2
      end
    end

    context 'when committee is inactive/complete' do
      let(:committee) { feed[:studentCommittees][0] }

      it 'correctly identifies a completed committee' do
        expect(committee[:isActive]).to be false
      end
      it 'includes both active members and members who have completed service' do
        expect(committee[:committeeMembers][:chair].count).to eq 3
      end
    end

    it 'correctly parses a qualifying exam committee when student has passed the exam' do
      committee = feed[:studentCommittees][0]
      expect(committee[:committeeType]).to eq 'Qualifying Exam Committee'
      expect(committee[:program]).to eq 'STUDENTACADPLAN1'
      expect(committee[:statusIcon]).to eq 'check'
      expect(committee[:statusMessage]).to eq nil
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
      expect(committee[:milestoneAttempts]).to eq []
    end

    it 'contains the expected student data for a Masters Thesis committee' do
      committee = feed[:studentCommittees][5]
      expect(committee[:committeeType]).to eq 'Master\'s Thesis Committee'
      expect(committee[:program]).to eq 'STUDENTACADPLAN6'
      expect(committee[:statusIcon]).to eq nil
      expect(committee[:statusMessage]).to eq 'Advanced: Jun 16, 2018'
      expect(committee[:milestoneAttempts]).to eq []
    end

    context 'when student has attempted the Qualifying Exam milestone' do
      it 'contains only the most recent attempt' do
        qualifying_exam_attempts = feed[:studentCommittees][0][:milestoneAttempts]
        expect(qualifying_exam_attempts.count).to eq 1
        expect(qualifying_exam_attempts[0][:sequenceNumber]).to eq 2
        expect(qualifying_exam_attempts[0][:date]).to eq 'Jan 01, 2015'
        expect(qualifying_exam_attempts[0][:result]).to eq 'Passed'
      end

      context 'when building a string to represent the attempt' do
        it 'includes the attempt number if student did not pass the first attempt' do
          qualifying_exam_attempts = feed[:studentCommittees][2][:milestoneAttempts]
          expect(qualifying_exam_attempts[0][:display]).to eq 'Exam 1: Failed Jan 01, 2014'
        end
        it 'does not include the attempt number if student passed the first attempt' do
          qualifying_exam_attempts = feed[:studentCommittees][4][:milestoneAttempts]
          expect(qualifying_exam_attempts[0][:display]).to eq 'Passed Jan 01, 2016'
        end
      end

      it 'has a blank status message' do
        expect(feed[:studentCommittees][0][:statusMessage]).to be nil
        expect(feed[:studentCommittees][2][:statusMessage]).to be nil
        expect(feed[:studentCommittees][4][:statusMessage]).to be nil
      end
    end

    context 'when student has not yet attempted the Qualifying Exam milestone' do
      let(:qe_committee_with_proposed_exam) { feed[:studentCommittees][6] }

      it 'has an empty attempts list' do
        expect(qe_committee_with_proposed_exam[:milestoneAttempts]).to eq []
      end

      it 'populates the status message with the proposed exam date' do
        expect(qe_committee_with_proposed_exam[:statusMessage]).to eq 'Proposed Exam Date: Dec 10, 2020'
      end
    end

    it 'contains the expected student committee data for chairs' do
      members = feed[:studentCommittees][0][:committeeMembers]

      expect(members[:chair][0][:name]).to eq 'MEMBERFIRSTNAME0 MEMBERLASTNAME0'
      expect(members[:chair][0][:email]).to eq 'MEMBER@EMAIL.0'
      expect(members[:chair][0][:primaryDepartment]).to eq 'MEMBERDEPTDESCR0'
      expect(members[:chair][0][:serviceRange]).to eq 'Jan 01, 2001 - Oct 10, 2001'

      expect(members[:chair][1][:name]).to eq 'MEMBERFIRSTNAME1 MEMBERLASTNAME1'
      expect(members[:chair][1][:email]).to eq 'MEMBER@EMAIL.1'
      expect(members[:chair][1][:primaryDepartment]).to eq 'MEMBERDEPTDESCR1'
      expect(members[:chair][1][:serviceRange]).to eq 'Jan 01, 2021 - Present'

      expect(members[:chair][2][:name]).to eq 'MEMBERFIRSTNAME2 MEMBERLASTNAME2'
      expect(members[:chair][2][:email]).to eq 'MEMBER@EMAIL.2'
      expect(members[:chair][2][:primaryDepartment]).to eq 'MEMBERDEPTDESCR2'
      expect(members[:chair][2][:serviceRange]).to eq 'Jan 01, 2022 - Present'
    end

    it 'contains the expected student committee data for co-chairs' do
      members = feed[:studentCommittees][0][:committeeMembers]
      expect(members[:coChair][0][:name]).to eq 'MEMBERFIRSTNAME3 MEMBERLASTNAME3'
      expect(members[:coChair][0][:email]).to eq 'MEMBER@EMAIL.3'
      expect(members[:coChair][0][:primaryDepartment]).to eq 'MEMBERDEPTDESCR3'
      expect(members[:coChair][0][:serviceRange]).to eq 'Jan 01, 2023 - Present'

      expect(members[:coChair][1][:name]).to eq 'MEMBERFIRSTNAME4 MEMBERLASTNAME4'
      expect(members[:coChair][1][:email]).to eq 'MEMBER@EMAIL.4'
      expect(members[:coChair][1][:primaryDepartment]).to eq 'MEMBERDEPTDESCR4'
      expect(members[:coChair][1][:serviceRange]).to eq 'Jan 01, 2024 - Present'
    end

    it 'contains the expected student committee data for additional reps' do
      members = feed[:studentCommittees][0][:committeeMembers]
      expect(members[:additionalReps][0][:name]).to eq 'MEMBERFIRSTNAME5 MEMBERLASTNAME5'
      expect(members[:additionalReps][0][:email]).to eq 'MEMBER@EMAIL.5'
      expect(members[:additionalReps][0][:primaryDepartment]).to eq 'MEMBERDEPTDESCR5'
      expect(members[:additionalReps][0][:serviceRange]).to eq 'Jan 01, 2025 - Present'

      expect(members[:additionalReps][1][:name]).to eq 'MEMBERFIRSTNAME6 MEMBERLASTNAME6'
      expect(members[:additionalReps][1][:email]).to eq 'MEMBER@EMAIL.6'
      expect(members[:additionalReps][1][:primaryDepartment]).to eq 'MEMBERDEPTDESCR6'
      expect(members[:additionalReps][1][:serviceRange]).to eq 'Jan 01, 2026 - Present'
    end

    it 'contains the expected student committee data for academic senate' do
      members = feed[:studentCommittees][0][:committeeMembers]
      expect(members[:academicSenate][0][:name]).to eq 'MEMBERFIRSTNAME7 MEMBERLASTNAME7'
      expect(members[:academicSenate][0][:email]).to eq 'MEMBER@EMAIL.7'
      expect(members[:academicSenate][0][:primaryDepartment]).to eq 'MEMBERDEPTDESCR7'
      expect(members[:academicSenate][0][:serviceRange]).to eq 'Jan 01, 2027 - Present'
    end
  end
end
