module Concerns
  module NewAdmits
    extend self

    def undergrad_new_admit? new_admit_status
      new_admit_status.try(:[], :sirStatuses).try(:find) {|status| status[:isUndergraduate]}
    end

    def first_year_pathway_fall_admit? new_admit_status
      first_year_admit?(new_admit_status, 'Fall')
    end

    def first_year_pathway_spring_admit? new_admit_status
      first_year_admit?(new_admit_status, 'Spring')
    end

    private

    def first_year_admit?(new_admit_status, term)
      undergrad_new_admit_status = new_admit_status.try(:[], :sirStatuses).try(:find) {|status| status[:isUndergraduate]}
      undergrad_new_admit_attributes = undergrad_new_admit_status.try(:[], :newAdmitAttributes)
      first_year_pathway = undergrad_new_admit_attributes.try(:[], :roles).try(:[], :firstYearPathway)
      admit_term = undergrad_new_admit_attributes.try(:[], :admitTerm)

      first_year_pathway && admit_term.try(:[], :type) == term
    end
  end
end
