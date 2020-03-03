describe User::Tasks::ChecklistItem do
  describe "#display_category" do
    it "is 'finances' if admin_function is BDGT" do
      subject = described_class.new({
        admin_function: 'BDGT',
        item_code: 'FVERA'
      })

      expect(subject.display_category).to eq('financialAid')
    end

    it "is 'residency' if item_code starts with 'RR'" do
      subject = described_class.new({ item_code: 'RR_RESIDENCY', admin_function: "ADMA" })
      expect(subject.display_category).to eq 'residency'
    end

    it "returns from DISPLAY_CATEGORIES by admin_function" do
      subject = described_class.new({ item_code: 'IRRELEVANT', admin_function: "ADMA" })
      expect(subject.display_category).to eq 'newStudent'
    end

    it "returns 'student' if the admin function is not recognized" do
      subject = described_class.new({ item_code: 'IRRELEVANT', admin_function: "UNKNOWN" })
      expect(subject.display_category).to eq 'student'
    end
  end

  describe "#ignored?" do
    it "is true if status_code is O, T, X" do
      %w(O T X).each do |example|
        subject = described_class.new({ status_code: example })
        expect(subject).to be_ignored
      end
    end

    it "is false is status_code is " do
      %w(A C I R W Z).each do |example|
        subject = described_class.new({ status_code: example })
        expect(subject).not_to be_ignored
      end
    end
  end


  describe "#sir?" do
    it "true if sir checklist code in SIR_CHECKLIST_CODES" do
      subject = described_class.new({ checklist_code: "AUSIR" })
      expect(subject).to be_sir
    end

    it "is false if other checklist code" do
      subject = described_class.new({ checklist_code: "RRTGRD" })
      expect(subject).not_to be_sir
    end
  end
end
