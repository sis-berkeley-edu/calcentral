module Advising
  class MyAdvising < UserSpecificModel

    include Cache::CachedFeed
    include Cache::FeedExceptionsHandled
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include DatedFeed
    include LinkFetcher

    RELATIONSHIP_ORDER = [
      'GSAO', # Graduate Student Affairs Offcr
      'HGA',  # Head Graduate Advisor
      'CHR',  # Department Chair
      'GEA',  # Graduate Equity Advisor
      'GRAD', # Grad Div Representative
      'COLL', # College Advisor
      'MAJ',  # Major Advisor
      'MIN',  # Minor Advisor
    ]

    def get_feed_internal
      advising_feed = {
        feed: {},
        statusCode: 200
      }

      if Settings.features.advising
        merge_action_items advising_feed
        merge_advisors advising_feed
        merge_links advising_feed
      end

      advising_feed
    end

    private

    def merge_action_items(advising_feed)
      merge_proxy_feed(advising_feed, CampusSolutions::AdvisorStudentActionItems) do |proxy_feed|
        if (action_items = proxy_feed.fetch(:ucAaActionItems, {}).fetch(:actionItems, nil))
          advising_feed[:feed][:actionItems] = []
          action_items.each do |item|
            next unless item[:actionItemStatus] == 'Incomplete'
            transform_date(item, :actionItemAssignedDate)
            transform_date(item, :actionItemDueDate)
            advising_feed[:feed][:actionItems] << item
          end
        end
      end
    end

    def merge_advisors(advising_feed)
      merge_proxy_feed(advising_feed, CampusSolutions::AdvisorStudentRelationship) do |proxy_feed|
        advisor_list = proxy_feed.fetch(:ucAaStudentAdvisor, {}).fetch(:studentAdvisor, nil)
        advising_feed[:feed][:advisors] = sort_advisors(advisor_list)
      end
    end

    def sort_advisors(advisors)
      return if advisors.nil?
      sorted_advisors = []
      grouped_advisors = advisors.group_by { |advisor| advisor[:assignedAdvisorTypeCode] }
      RELATIONSHIP_ORDER.each do |type|
        matched_advisors = grouped_advisors.delete(type).to_a
        sorted_advisors.concat(matched_advisors)
      end
      sorted_advisors.concat(grouped_advisors.values.flatten) unless student_is_graduate?
      sorted_advisors
    end

    def merge_links(advising_feed)
      manage_appointments_link = fetch_link 'UC_CX_APPOINTMENT_STD_MY_APPTS'
      new_appointment_link = fetch_link 'UC_CX_APPOINTMENT_STD_ADD'
      if manage_appointments_link && new_appointment_link
        advising_feed[:feed][:links] = {
          manageAppointments: manage_appointments_link,
          newAppointment: new_appointment_link
        }
      end
    end

    def merge_proxy_feed(advising_feed, proxy_class)
      response = proxy_class.new(user_id: @uid).get
      if !response || response[:errored] || !response[:feed].is_a?(Hash)
        advising_feed[:statusCode] = 500
        advising_feed[:errored] = true
        logger.error "Got errors in merged MyAdvising feed on #{proxy_class} for uid #{@uid} with response #{response}"
      else
        yield response[:feed]
      end
    end

    def transform_date(item, key)
      item[key] = format_date Time.zone.parse(item[key]).to_datetime
    end

    def student_is_graduate?
      college_and_level = MyAcademics::CollegeAndLevel.new(@uid)
      plans = college_and_level.hub_college_and_level[:plans]
      career_codes = plans.to_a.collect {|plan| plan[:career].try(:[], :code) }
      career_codes.include?('GRAD')
    end
  end
end
