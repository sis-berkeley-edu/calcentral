require "spec_helper"

RSpec.describe User::Academics::Status::Postgraduate, type: :model do
  describe "#status_message" do
    describe "when tutition is calculated" do
      let(:term_registration) {
        instance_double("User::Academics::TermRegistration").tap do |mock|
          allow(mock).to receive(:summer?).and_return(false)
          allow(mock).to receive(:enrolled?).and_return(true)
          allow(mock).to receive(:tuition_calculated?).and_return(true)
          allow(mock).to receive(:registered?).and_return(false)
          allow(mock).to receive(:twenty_percent_cnp_exception?).and_return(false)
        end
      }

      subject { described_class.new(term_registration) }

      it 'is "Fees Unpaid"' do
        expect(subject.message).to eq "Fees unpaid"
      end

      describe "with SF20% CNP Exception" do
        it 'is "Limited Access"' do
          allow(term_registration).to receive(:twenty_percent_cnp_exception?).and_return(true)
          expect(subject.message).to eq 'Limited access to campus services'
        end
      end

      describe "and registered" do
        it 'is "You have access..."' do
          allow(term_registration).to receive(:registered?).and_return(true)
          expect(subject.message).to eq "You have access to campus services"
        end

        describe "with no enrolled classes" do
          it 'is "Not Enrolled"' do
            allow(term_registration).to receive(:enrolled?).and_return(false)
            expect(subject.message).to eq "Not enrolled"
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
        ['Fees unpaid', 'notice'],
        ['Limited access to campus services', 'notice'],
        ['Not enrolled', 'warning'],
        ['You have access to campus services', 'normal']
      ].each do |example|
        message, severity = *example
        subject = described_class.new(term_registration)
        allow(subject).to receive(:message).and_return(message)
        expect(subject.severity).to eq(severity), %Q[expected severity "#{severity}" for message "#{message}". Got "#{subject.severity}" instead.]
      end
    end
  end

  describe "comparison with #<=>" do
    let(:term_registration) { instance_double("User::Academics::TermRegistration") }

    def status_with_message(message)
      User::Academics::Status::Postgraduate.new(term_registration).tap do |instance|
        allow(instance).to receive(:message).and_return(message)
      end
    end

    it "sorts Statuses by message priority" do
      fees_unpaid = status_with_message('Fees unpaid')
      limited = status_with_message('Limited access to campus services')
      has_access = status_with_message('You have access to campus services')
      not_enrolled = status_with_message('Not Enrolled')

      unsorted = [has_access, limited, not_enrolled, fees_unpaid]
      sorted = [fees_unpaid, limited, has_access, not_enrolled]

      expect(unsorted.sort).to eq(sorted)
    end
  end
end
