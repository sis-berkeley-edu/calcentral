module Concerns
  module AcademicStatus
    extend self

    def academic_statuses(feed)
      feed.try(:[], :feed).try(:[], 'student').try(:[], 'academicStatuses') || []
    end

    def active?(plan)
      plan.try(:[], 'statusInPlan').try(:[], 'status').try(:[], 'code') == 'AC'
    end

    def active_plans_from_statuses(statuses)
      [].tap do |plans|
        statuses.try(:each) do |status|
          status.try(:[], 'studentPlans').try(:each) do |plan|
            if active? plan
              plan[:careerRole] = status.try(:[], 'studentCareer').try(:[], :role)
              plans.push(plan)
            end
          end
        end
      end
    end

    def all_grad_law_statuses(statuses)
      statuses.try(:select) do |status|
        role = status.try(:[], 'studentCareer').try(:[], :role)
        role == 'law' || role == 'grad'
      end
    end

    def all_law_statuses(statuses)
      statuses.try(:select) do |status|
        status.try(:[], 'studentCareer').try(:[], :role) == 'law'
      end
    end

    def all_undergraduate_statuses(statuses)
      statuses.try(:select) do |status|
        status.try(:[], 'studentCareer').try(:[], :role) == 'ugrd'
      end
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

    def has_holds?(feed)
      holds = feed.try(:[], :feed).try(:[], 'student').try(:[], 'holds') || []
      (holds.try(:to_a).try(:length) || 0) > 0
    end
  end
end
