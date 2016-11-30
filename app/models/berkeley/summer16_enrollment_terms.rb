module Berkeley
  module Summer16EnrollmentTerms
    extend self

    # When fetching enrollments and sections from the EDO Oracle DB and the legacy Campus Oracle DB, we need to query
    # for the summer-2016 term in both datasources.  This is because some students ("dual-citizens") have two SIDs, and
    # their summer-2016 enrollments are stored under one ID in the EDO DB and under the other ID in the legacy DB.
    #
    # Including summer-2016 in both terms lists (legacy and non-legacy) allows these students to see their summer-2016
    # data when logging in with either SID.

    def legacy_terms
      # Legacy terms are those before and including Settings.terms.legacy_cutoff.
      Berkeley::Terms.fetch.campus.values.select &:legacy?
    end

    def non_legacy_terms
      # Non-legacy terms are those after and including Settings.terms.legacy_cutoff.
      Berkeley::Terms.fetch.campus.values.select do |term|
        non_legacy_inclusive? term
      end
    end

    def non_legacy_inclusive? term
      term[:campus_solutions_id] >= TermCodes.slug_to_edo_id(Settings.terms.legacy_cutoff)
    end

  end
end
