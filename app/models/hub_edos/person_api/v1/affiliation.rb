module HubEdos
  module PersonApi
    module V1
      class Affiliation
        MATRICULATED_TYPE_CODE = 'APPLICANT'
        MATRICULATED_DETAILS_TO_EXCLUDE = [
          'SIR Completed',
          'Deposit Pending'
        ]

        def initialize(data)
          @data = data || {}
        end

        # a short descriptor representing the kind of affiation, such as student or employee, etc.
        def type
          HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
        end

        # a more detailed description for state of the affiliation, such as admitted or retired	string
        def detail
          @data['detail']
        end

        # a short descriptor representing the state of the affiliation, such as active or inactive, etc.
        def status
          HubEdos::Common::Reference::Descriptor.new(@data['status']) if @data['status']
        end

        # the date this affiliation became effective
        def from_date
          Date.parse(@data['fromDate']) if @data['fromDate']
        end

        def matriculated_but_excluded?
          type.code == MATRICULATED_TYPE_CODE && MATRICULATED_DETAILS_TO_EXCLUDE.include?(detail)
        end

        def is_student?
          type.code == 'STUDENT'
        end

        def as_json(options={})
          {
            type: type,
            detail: detail,
            status: status,
            fromDate: from_date.to_s,
          }.compact
        end
      end
    end
  end
end
