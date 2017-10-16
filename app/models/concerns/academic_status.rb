module Concerns
  module AcademicStatus
    extend self

    def academic_statuses(feed)
      feed.try(:[], :feed).try(:[], 'student').try(:[], 'academicStatuses') || []
    end

    def careers(statuses)
      [].tap do |careers|
        statuses.try(:each) do |status|
          if (career = status['studentCareer'].try(:[], 'academicCareer'))
            careers << career
          end
        end
      end.uniq
    end

    def newest_career(statuses)
      newest_career_status = statuses.try(:sort) do |this_status, that_status|
        this_from_date = this_status['studentCareer'].try(:[], 'fromDate').to_s
        that_from_date = that_status['studentCareer'].try(:[], 'fromDate').to_s
        this_from_date <=> that_from_date
      end.try(:last)
      newest_career_status.try(:[], 'studentCareer').try(:[], 'academicCareer')
    end

    def active?(plan)
      plan.try(:[], 'statusInPlan').try(:[], 'status').try(:[], 'code') == 'AC'
    end

    def has_holds?(feed)
      holds = feed.try(:[], :feed).try(:[], 'student').try(:[], 'holds') || []
      (holds.try(:to_a).try(:length) || 0) > 0
    end
  end
end
