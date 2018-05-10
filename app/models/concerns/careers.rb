module Concerns
  module Careers
    extend self

    def active? career
      :AC == career.try(:[], 'program_status').try(:intern)
    end

    def active_or_all careers
      active_careers = careers.try(:select){|career| active? career}
      active_careers.present? ? active_careers : careers
    end
  end
end
