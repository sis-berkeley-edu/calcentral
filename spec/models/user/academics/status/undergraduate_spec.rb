require "spec_helper"

RSpec.describe User::Academics::Status::Undergraduate, type: :model do
  describe "#message" do
    describe "when tutition is calculated" do
      let(:term_registration) {
        instance_double("User::Academics::TermRegistration").tap do |mock|
          allow(mock).to receive(:summer?).and_return(false)
          allow(mock).to receive(:enrolled?).and_return(true)
          allow(mock).to receive(:tuition_calculated?).and_return(true)
          allow(mock).to receive(:registered?).and_return(false)
        end
      }

      subject { described_class.new(term_registration) }

      it 'is "Not Officially Registered"' do
        expect(subject.message).to eq "Not Officially Registered"
      end

      describe "with CNP Exception" do
        it 'is "Not Officially Registered"' do
          allow(term_registration).to receive(:twenty_percent_cnp_exception?).and_return(true)
          expect(subject.message).to eq "Not Officially Registered"
        end

        describe "and registered" do
          it 'is "Officially Registered..."' do
            allow(term_registration).to receive(:cnp_exception?).and_return(true)
            allow(term_registration).to receive(:registered?).and_return(true)
            expect(subject.message).to eq "Officially Registered"
          end
        end
      end

      describe "and registered" do
        it 'is "Officially Registered"' do
          allow(term_registration).to receive(:registered?).and_return(true)
          expect(subject.message).to eq "Officially Registered"
        end

        describe "with no enrolled classes" do
          it 'is "Not Enrolled"' do
            allow(term_registration).to receive(:enrolled?).and_return(false)
            expect(subject.message).to eq "Not Enrolled"
          end
        end
      end
    end
  end

  describe "#severity" do
    let(:term_registration) {
      instance_double("User::Academics::TermRegistration")
    }

    it 'is "warning" unless officially registered' do
      [
        ['Not Officially Registered', 'warning'],
        ['Not Enrolled', 'warning'],
        ['Officially Registered', 'normal']
      ].each do |example|
        message, severity = *example
        subject = described_class.new(term_registration)
        allow(subject).to receive(:message).and_return(message)
        expect(subject.severity).to eq(severity), %Q[expected severity "#{severity}" for message "#{message}". Got "#{subject.severity}" instead.]
      end
    end
  end
end
