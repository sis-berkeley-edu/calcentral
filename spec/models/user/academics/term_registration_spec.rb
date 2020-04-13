require 'spec_helper'

RSpec.describe User::Academics::TermRegistration, type: :model do
  let(:term) { instance_double("User::Academics::Term") }
  let(:user) { instance_double("User::Current") }

  subject { User::Academics::TermRegistration.new(user, term) }

  describe "#status_message" do
    describe "for a summer term" do
      it "is nil" do
        expect(subject).to receive(:summer?).and_return(true)
        expect(subject.status_message).to eq nil
      end
    end

    describe "before tuition calculation" do
      it "is nil" do
        subject = User::Academics::TermRegistration.new(user, term)
        expect(subject).to receive(:summer?).and_return(false)
        expect(subject).to receive(:tuition_calculated?).and_return(false)
        expect(subject.status_message).to eq nil
      end
    end

    it "delegates to the #career_status for regular, tuition calculated terms" do
      generic_career_status = instance_double("User::Academics::Status::Base").tap do |mock|
        expect(mock).to receive(:message).and_return("Around campus")
      end

      subject = User::Academics::TermRegistration.new(user, term)
      expect(subject).to receive(:registration_status).and_return(generic_career_status)
      expect(subject.status_message).to eq "Around campus"
    end
  end

  describe "#registration_status" do
    subject { User::Academics::TermRegistration.new(user, term) }

    it "is a NullStatus during summer terms" do
      allow(subject).to receive(:summer?).and_return(true)
      expect(subject.registration_status).to be_an_instance_of(User::Academics::Status::NullStatus)
    end

    it "is a NullStatus before tuition is calculated" do
      allow(subject).to receive(:summer?).and_return(false)
      allow(subject).to receive(:tuition_calculated?).and_return(false)
      expect(subject.registration_status).to be_an_instance_of(User::Academics::Status::NullStatus)
    end

    it "is a NullStatus when not an UGRD, GRAD or LAW student (UCBX)" do
      allow(subject).to receive(:summer?).and_return(false)
      allow(subject).to receive(:tuition_calculated?).and_return(true)
      allow(subject).to receive(:undergraduate?).and_return(false)
      allow(subject).to receive(:graduate?).and_return(false)
      allow(subject).to receive(:law?).and_return(false)
      expect(subject.registration_status).to be_an_instance_of(User::Academics::Status::NullStatus)
    end

    it "is an Academics::Status::Undergraduate when #undergraduate?" do
      allow(subject).to receive(:summer?).and_return(false)
      allow(subject).to receive(:tuition_calculated?).and_return(true)
      allow(subject).to receive(:undergraduate?).and_return(true)
      expect(subject.registration_status).to be_an_instance_of(User::Academics::Status::Undergraduate)
    end

    it "is an Academics::Status::Postgraduate when #graduate?" do
      allow(subject).to receive(:summer?).and_return(false)
      allow(subject).to receive(:tuition_calculated?).and_return(true)
      allow(subject).to receive(:undergraduate?).and_return(false)
      allow(subject).to receive(:graduate?).and_return(true)
      allow(subject).to receive(:law?).and_return(false)
      expect(subject.registration_status).to be_an_instance_of(User::Academics::Status::Postgraduate)
    end

    it "is an Academics::Status::Postgraduate when #law?" do
      allow(subject).to receive(:summer?).and_return(false)
      allow(subject).to receive(:tuition_calculated?).and_return(true)
      allow(subject).to receive(:undergraduate?).and_return(false)
      allow(subject).to receive(:graduate?).and_return(false)
      allow(subject).to receive(:law?).and_return(true)
      expect(subject.registration_status).to be_an_instance_of(User::Academics::Status::Postgraduate)
    end

    it "is an Academics::Status::Concurrent when #law? and #graduate?" do
      allow(subject).to receive(:summer?).and_return(false)
      allow(subject).to receive(:tuition_calculated?).and_return(true)
      allow(subject).to receive(:undergraduate?).and_return(false)
      allow(subject).to receive(:graduate?).and_return(true)
      allow(subject).to receive(:law?).and_return(true)
      expect(subject.registration_status).to be_an_instance_of(User::Academics::Status::Concurrent)
    end
  end
end
