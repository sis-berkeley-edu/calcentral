describe User::Tasks::Agreement do
  describe "#display_category" do
    it "is financialAid if admin_function is BDGT" do
      subject = described_class.new(admin_function: "BDGT")
      expect(subject.display_category).to eq "financialAid"
    end
  end

  describe "#financial_aid?" do
    it "true if admin_function is 'FINA'" do
      subject = described_class.new(admin_function: "FINA")
      expect(subject).to be_financial_aid
    end

    it "false if admin_function is something else (even other finances categories)" do
      %w[SFAC BDGT].each do |string|
        subject = described_class.new(admin_function: string)
        expect(subject).not_to be_financial_aid
      end
    end
  end

  describe "#as_json" do
    it "returns default keys" do
      subject = described_class.new(admin_function: "BDGT")

      expect(subject.as_json.keys).to eq([
        :displayCategory,
        :isFinancialAid
      ])
    end
  end
end
