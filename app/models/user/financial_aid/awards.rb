module User
  module FinancialAid
    class Awards
      include ActiveModel::Model

      attr_accessor :uid
      attr_accessor :aid_year
      attr_accessor :effective_date

      def all
        @all ||= all_awards_data.collect do |award_data|
          Award.new(award_data)
        end
      end

      def as_json(options={})
        {
          total: all.collect(&:value).sum,
          awardTypes: types.collect do |type|
            AwardType.new(type).as_json.merge({
              items: for_type(type)
            })
          end
        }
      end

      def for_type(type)
        all.select do |award|
          award.type == type
        end
      end

      def types
        all.collect(&:award_type).uniq
      end

      private

      def all_awards_data
        @all_awards_data ||= Queries.get_award_comparison_awards(@uid, aid_year: @aid_year, effective_date: @effective_date)
      end
    end
  end
end

