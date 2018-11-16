module CampusSolutions
  module FinancialAidExpiry
    def self.expire(uid=nil)
      [
        MyAidYears,
        MyFinancialAidData,
        MyFinancialAidFundingSources,
        MyFinancialAidFundingSourcesTerm,
        FinancialAid::MyFinancialAidSummary,
        FinancialAid::MyHousing
      ].each do |klass|
        klass.expire uid
      end
    end
  end
end
