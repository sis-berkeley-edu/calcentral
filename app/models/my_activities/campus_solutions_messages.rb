module MyActivities
  class CampusSolutionsMessages
    include ClassLogger, DatedFeed, HtmlSanitizer, SafeJsonParser

    def self.append!(uid, activities)
      messages = get_feed uid
      activities.concat messages
    end

    def self.get_feed(uid)
      feed = CampusSolutions::PendingMessages.new(user_id: uid).get[:feed]
      results = []
      if feed && feed[:commMessagePendingResponse]
        feed[:commMessagePendingResponse].each do |message|
          if message[:descr].present?
            formatted_entry = {
              emitter: CampusSolutions::Proxy::APP_NAME,
              id: '',
              linkText: 'Read more',
              source: message[:commCatgDescr],
              summary: message[:commCenterDescr],
              type: 'campusSolutions',
              title: message[:descr],
              user_id: uid,
              date: format_date(strptime_in_time_zone(message[:lastupddttm], "%Y-%m-%d-%H.%M.%S.%N")), # 2015-12-01-14.09.04.701033
              sourceUrl: message[:url],
              url: message[:url],
              cs: {}
            }

            if message[:adminFunction].is_a?(Hash) && message[:adminFunction][:varSeqData] && (FinancialAid::Shared::ADMIN_FUNCTION.include? message[:adminFunction][:adminFunction])
              formatted_entry[:cs].merge!({
                isFinaid: true,
                finaidYearId: message[:adminFunction][:varSeqData][:aidYear]
              })
            end

            results << formatted_entry
          end
        end
      end
      results
    end

  end
end
