module StudentSuccess
  class OutstandingBalance

    def initialize(opts={})
      @student_uid_param = opts[:user_id]
    end

    def merge(data={})
      data[:outstandingBalance] = outstanding_balance
    end

    def outstanding_balance
      response = CampusSolutions::StudentOutstandingBalance.new(user_id: @student_uid_param).get
      parse_outstanding_balance response
    end

    def parse_outstanding_balance(response)
      balance = response.try(:[], :feed).try(:[], :ucSfAccountData).try(:[], :outstandingBalance)
      if balance
        balance = balance.gsub(/[$,]/, '')
        return balance.to_f
      end
      nil
    end
  end
end
