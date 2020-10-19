module CampusSolutions
  module FinancialAidExpiry
    def self.expire(uid=nil)
      [
        MyFinancialAidData,
        FinancialAid::MyAidYears,
        FinancialAid::MyAwards,
        FinancialAid::MyAwardsByTerm,
        FinancialAid::MyFinaidProfile,
        FinancialAid::MyFinancialAidSummary,
        FinancialAid::MyHousing,
      ].each do |klass|
        klass.expire uid
      end
    end
  end
end
