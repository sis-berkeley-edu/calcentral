module User
  class Affiliation
    attr_reader :data

    MATRICULATED_TYPE_CODE = 'APPLICANT'
    MATRICULATED_DETAILS_TO_EXCLUDE = [
      'SIR Completed',
      'Deposit Pending'
    ]

    def initialize(data)
      @data = data
    end

    def matriculated_but_excluded?
      type_code == MATRICULATED_TYPE_CODE && MATRICULATED_DETAILS_TO_EXCLUDE.include?(detail)
    end

    def detail
      data['detail']
    end

    def type_code
      data['type']['code']
    end
  end
end
