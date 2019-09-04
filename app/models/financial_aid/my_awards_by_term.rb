module FinancialAid
  class MyAwardsByTerm < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::RelatedCacheKeyTracker
    include CampusSolutions::FinaidFeatureFlagged
    include LinkFetcher


    def get_feed_internal
      return {} unless is_feature_enabled
      {
        feed: {
          awards: awards,
          message: CampusSolutions::MessageCatalog.get_message(:financial_aid_awards_card_info).try(:[], :descrlong)
        },
        errored: award_types ? false : true
      }
    end

    def instance_key
      "#{@uid}-#{my_aid_year}"
    end

    private

    def awards
      return nil unless award_types
      {
        semester: {
          data: award_data
        }
      }
    end

    def award_types
      @award_types ||= EdoOracle::FinancialAid::Queries.get_awards_by_term_types(@uid, my_aid_year)
    end

    def my_aid_year
      @my_aid_year ||= (@options[:aid_year] || FinancialAid::MyAidYears.new(@uid).default_aid_year).to_i.to_s
    end

    def award_data
      return award_data unless award_types
      award_data = []
      @grand_total_fall = 0
      @grand_total_spring = 0
      @grand_total_summer = 0
      @grand_total = 0

      award_types.map.try(:each) do |item|
        award_type = {
          headers: headers,
          items: award_items(item['award_type']),
          title: item['award_type_descr']
        }

        award_data.push(award_type)
      end

      totals = {
        headers: headers,
        items: [
          { amounts:
            [
              @grand_total_fall > 0 ? @grand_total_fall : nil,
              @grand_total_spring > 0 ? @grand_total_spring : nil,
              @grand_total_summer > 0 ? @grand_total_summer : nil,
              @grand_total > 0 ? @grand_total : nil
            ]
          }
        ],
        title: 'Grand Total'
      }

      award_data.push(totals)
    end

    def headers
      ['Fall', 'Spring', 'Summer', 'Total']
    end

    def award_items(award_type)
      results ||= EdoOracle::FinancialAid::Queries.get_awards_by_term_by_type(@uid, my_aid_year, award_type)

      return null unless results
      items = []
      award_type_total_fall = 0
      award_type_total_spring = 0
      award_type_total_summer = 0
      award_type_total = 0

      results.map.try(:each) do |item|
      award_type_total_fall += item['amount_fall'].to_f
      award_type_total_spring += item['amount_spring'].to_f
      award_type_total_summer += item['amount_summer'].to_f
      award_type_total += (item['amount_fall'].to_f + item['amount_spring'].to_f + item['amount_summer'].to_f)
      @grand_total_fall += item['amount_fall'].to_f
      @grand_total_spring += item['amount_spring'].to_f
      @grand_total_summer += item['amount_summer'].to_f
      @grand_total += (item['amount_fall'].to_f + item['amount_spring'].to_f + item['amount_summer'].to_f)

      award_item = {
        amounts:
          [
            item['amount_fall'].to_f > 0 ? item['amount_fall'].to_f : nil,
            item['amount_spring'].to_f > 0 ? item['amount_spring'].to_f : nil,
            item['amount_summer'].to_f > 0 ? item['amount_summer'].to_f : nil
          ],
        total: item['amount_fall'].to_f + item['amount_spring'].to_f + item['amount_summer'].to_f,
        title: item['title']
      }

      items.push(award_item)

      end

      totals = {
        totals:
          [
            award_type_total_fall > 0 ? award_type_total_fall : nil,
            award_type_total_spring > 0 ? award_type_total_spring : nil,
            award_type_total_summer > 0 ? award_type_total_summer : nil,
            award_type_total > 0 ? award_type_total : nil
          ]
      }

      items.push(totals)
    end
  end
end
