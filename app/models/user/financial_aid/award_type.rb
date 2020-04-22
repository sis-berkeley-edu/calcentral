module User
  module FinancialAid
    class AwardType
      KNOWN_TYPES = {
        'giftaid' => 'Gift Aid',
        'waiversAndOther' => 'Waivers and Other Funding',
        'workstudy' => 'Work-Study',
        'subsidizedloans' => 'Subsidized Loans',
        'unsubsidizedloans' => 'Unsubsidized Loans',
        'plusloans' => 'PLUS Loans',
        'alternativeloans' => 'Alternative Loans'
      }

      def initialize(type)
        @type = type
      end

      def as_json(options={})
        {
          type: @type,
          description: description
        }
      end

      def description
        KNOWN_TYPES.fetch(@type) { "ERROR" }
      end
    end
  end
end

