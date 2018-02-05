module MyAcademics
  class GradingDates
    extend Cache::Cacheable

    def self.fetch(options = {})
      smart_fetch_from_cache(force_write: options[:force]) do
        get_grading_dates
      end
    end

    def self.get_grading_dates(options = {})
      grading_dates = {}
      EdoOracle::Queries.get_grading_dates.each do |edo_grading_period|
        term_id = edo_grading_period['term_id']
        acad_career = edo_grading_period['acad_career']
        session_code = edo_grading_period['session_code']
        grading_dates[term_id] ||= {}
        grading_dates[term_id][acad_career] ||= {}
        grading_info = edo_grading_period.slice('mid_term_begin_date', 'mid_term_end_date', 'final_begin_date', 'final_end_date').symbolize_keys
        grading_info.keys.each do |date_key|
          grading_info[date_key] = grading_info[date_key].to_date if grading_info[date_key].present?
        end
        grading_info[:hasMidTerm] = (grading_info[:mid_term_begin_date].present? && grading_info[:mid_term_begin_date].present?)
        grading_dates[term_id][acad_career][session_code] = grading_info
      end
      grading_dates
    end
  end
end
