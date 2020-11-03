module MyRegistrations
  class FlaggedTerms
    def get
      @berkeley_terms ||= Proc.new do
        terms = {}
        raw_terms = Berkeley::Terms.fetch
        # current, running, and sis_current_term can all potentially be different depending on where we are in the academic year.
        # So, we grab all of them in case of term transitions.
        [:current, :running, :sis_current_term, :next, :future].each do |term_method|
          if (term = raw_terms.send term_method)
            # We need various dates to determine CNP status
            terms[term_method] = {
              id: term.campus_solutions_id,
              name: term.to_english,
              classesStart: term.classes_start,
              end: term.end,
              endDropAdd: term.end_drop_add
            }
            terms[term_method] = set_term_flags(terms[term_method])
          # Often ':future' will be nil, but during Spring terms, it should send back data for the upcoming Fall semester.
          else
            terms[term_method] = nil
          end
        end
        terms
      end.call
    end

    private

    def set_term_flags(term)
      current_date = Settings.terms.fake_now || Cache::CacheableDateTime.new(DateTime.now)
      term.merge({
        # CNP logic dictates that grad/law students are dropped one day AFTER the add/drop deadline.
        pastAddDrop: term[:endDropAdd] ? current_date > term[:endDropAdd] : nil,
        # Undergrad students are dropped on the first day of instruction.
        pastClassesStart: current_date >= term[:classesStart],
        # All term registration statuses are hidden the day after the term ends.
        pastEndOfInstruction: current_date > term[:end],
        # Financial Aid disbursement is used in CNP notification.  This is defined as 9 days before the start of instruction.
        pastFinancialDisbursement: current_date >= (term[:classesStart] - 9),
      })
    end

  end
end
