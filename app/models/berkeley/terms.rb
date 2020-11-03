# Our campus DB may contain data for many semesters excluded from CalCentral. Semesters of interest vary by
# functional domain:
#
#   * My Academics :
#       - Currently running term (if any; there are gaps between terms)
#       - Past terms back to a configured cut-off
#       - The next term, when available
#       - In Spring, the next Fall term, when available
#   * My Classes :
#       - Currently running term, if any; otherwise the next term
#   * bCourses course provisioning & refreshes :
#       - Currently running term (if any)
#       - The next term, when available
#       - In Spring, the next Fall term, when available
#   * FinAid :
#       - Always display the "current Aid Year", which is defined as:
#           - After the end of the Summer term, the next calendar year
#           - Up to and including the last day of this year's Summer term, the current calendar year
#       - Also display the "next Aid Year" between "the day admissions letters are released"
#         and the last day of Summer term. The admissions-release day is not available in the
#         campus DB, and so it is maintained in the CalCentral application DB.

module Berkeley
  class Terms
    include ActiveAttrModel, ClassLogger, DatedFeed
    extend Cache::Cacheable

    # The term shown in the My Classes widget & highlighted in the top Academics page.
    attr_reader :current
    # The term officially in progress. The academic calendar has gaps, and so this will sometimes be nil.
    attr_reader :running
    # The "Current Term" (or "CT") in legacy SIS systems such as Bear Facts.
    attr_reader :sis_current_term
    # The next term (after the current one).
    attr_reader :next
    # The next term after the next term. This will often be nil but is particularly useful
    # during Spring terms, when most instructors and most enrolled students will have more
    # interest in the Fall schedule than in Summer classes.
    attr_reader :future
    # The previous term (before the current one).
    attr_reader :previous
    # The previous term immediately after its official end, while final
    # grades are being posted.
    attr_reader :grading_in_progress
    # How far back do we look for enrollments, transcripts, & teaching assignments?
    attr_reader :oldest
    # Full list of terms in DB.
    attr_reader :campus

    def self.fetch(options = {})
      Rails.logger.debug "fetching terms"
      options.reverse_merge!(
        fake_now: Settings.terms.fake_now,
        oldest: Settings.terms.oldest,
        hub_api_disabled: !Settings.features.hub_term_api
      )
      Rails.logger.debug "options: #{options.inspect}"
      smart_fetch_from_cache(force_write: options[:force]) do
        terms = Terms.new(options)
        terms.init
      end
    end

    def self.find_by_campus_solutions_id(term_id, options = {})
      terms = fetch(options).campus
      fetch(options).campus.values.find {|t| t.campus_solutions_id == term_id}
    end

    def self.legacy?(term_yr, term_cd)
      term = self.fetch.campus[Berkeley::TermCodes.to_slug(term_yr, term_cd)]
      term.present? && term.legacy?
    end

    def self.campus_solutions_id_to_name(campus_solutions_id)
      century_num = "#{campus_solutions_id.to_s[0]}"
      century = case century_num
        when '1'
          '19'
        when '2'
          '20'
        else
          raise ArgumentError, "Invalid century number for '#{campus_solutions_id}'. Must begin with '1' or '2'"
      end
      year = campus_solutions_id.to_s[1..2]
      term_num = campus_solutions_id.to_s[3]
      term_name = case term_num
        when '2'
          'Spring'
        when '5'
          'Summer'
        when '8'
          'Fall'
        else
          raise ArgumentError, "Invalid term number for '#{campus_solutions_id}'. Must end with '2', '5', or '8'"
      end
      "#{term_name} #{century}#{year}"
    end

    def initialize(options)
      @current_date = options[:fake_now] || Cache::CacheableDateTime.new(DateTime.now)
      @oldest = options[:oldest]
      @hub_api_disabled = options[:hub_api_disabled]
    end

    def init
      # The final terms map is ordered newest-to-oldest.
      terms = {}
      # We stash future terms in oldest-to-newest order so as to limit the number of future terms
      # used in CalCentral/Junction.
      future_terms = []

      # Do initial term parsing.
      terms_array = fetch_terms_from_api

      merge_terms_from_legacy_db terms_array if Settings.features.allow_legacy_fallback

      # Classify and map terms.
      terms_array.each do |term|
        terms[term.slug] = term
        if term.start > @current_date
          future_terms.push term
        elsif term.end >= @current_date
          @running = term
          @sis_current_term = term
        else
          @previous ||= term
          @grading_in_progress ||= term if term.grades_entered >= @current_date
        end
      end

      @current = @running || future_terms.pop
      if (@next = future_terms.pop)
        # Temporary workaround for Summer 2016, during which legacy SIS says the "current term" is Fall 2016 but CS SIS
        # says the "current term" is Summer 2016.
        @sis_current_term ||= @next if @current.legacy? && @current.is_summer && !@next.legacy?
        @future = future_terms.pop
        unless future_terms.empty?
          logger.info("Found more than two future terms: #{future_terms.map(&:slug).join(', ')}")
          future_terms.each {|t| terms.delete(t.slug)}
        end
      end
      @campus = terms
      self
    end

    def load_terms_from_file
      cs_terms = []
      filename = Settings.terms.term_definitions_json_file
      begin
        filename = Settings.terms.term_definitions_json_file || "#{Rails.root}/public/json/terms.json"
        contents = File.read(filename)
        json_terms = JSON.parse(contents)
      end
      json_terms.each do |term|
        new_term = Berkeley::Term.new.from_json_file(term)
        cs_terms << new_term
      end
      cs_terms
    end

    def load_terms_from_edo_db
      cs_terms = []
      edo_db_terms = EdoOracle::Queries.get_undergrad_terms
      edo_db_terms.each_with_index do |term, index|
        new_term = Berkeley::Term.new.from_edo_db(term)
        cs_terms << new_term
        # Only keep 2 future terms in array
        cs_terms.shift if is_future_term?(new_term) && index > 1
      end
      cs_terms
    end

    def is_future_term?(new_term)
      new_term.start > @current_date
    end

    def fetch_terms_from_api
      # Unlike the legacy database view, the HubTerm API does not support bulk queries. We have to
      # loop through enough API calls to find:
      #   - Current term (if any)
      #   - Next term
      #   - Next term after the end of the next term (if available)
      #   - Previous term
      #   - Previous term before the previous term
      #   - ... and so on until we reach either the oldest configured term or the legacy_cutoff configured term.
      # For backwards compatibility, we will stash the Term objects in descending chronological order.
      # Because there is a possibility that no academic term is current today, the loop starts from the next term.
      cs_terms = []
      # If hub term API is disabled, load terms from json file if enabled
      if @hub_api_disabled
        if Settings.terms.use_term_definitions_json_file
          return load_terms_from_file
        else
          return load_terms_from_edo_db
        end
      end
      feed = HubTerm::Proxy.new(temporal_position: HubTerm::Proxy::NEXT_TERM).get_term
      if feed.blank?
        logger.error "No Next term found from HubTerm::Proxy; no non-legacy academic terms are available"
      else
        term = Berkeley::Term.new.from_cs_api(feed)
        cs_terms << term unless term.legacy? && Settings.features.allow_legacy_fallback
        term_date = term.end.to_date.to_s
        if (next_after_next = HubTerm::Proxy.new(temporal_position: HubTerm::Proxy::NEXT_TERM, as_of_date: term_date).get_term)
          cs_terms.unshift Berkeley::Term.new.from_cs_api(next_after_next)
        end
        loop do
          term_date = term.start.to_date.to_s
          feed = HubTerm::Proxy.new(temporal_position: HubTerm::Proxy::PREVIOUS_TERM, as_of_date: term_date).get_term
          break unless feed.present?
          term = Berkeley::Term.new.from_cs_api(feed)
          break if term.legacy? && Settings.features.allow_legacy_fallback
          @sis_current_term = term if term.sis_current_term?
          cs_terms << term
          break if term.slug == @oldest
        end
      end
      cs_terms
    end

    def merge_terms_from_legacy_db(terms)
      CampusOracle::Queries.terms.each do |db_term|
        term = Term.new(db_term)
        if term.legacy? || @hub_api_disabled
          @sis_current_term ||= term if term.legacy_sis_term_status == 'CT'
          terms << term
        end
        break if term.slug == @oldest
      end
      terms
    end

    # True if the current term in CalCentral UX is not the official "current term" in SIS.
    # In CS SIS, this will probably only happen when between the end date of one term and the
    # start date of the next. In legacy SIS, it was also true during the Summer term.
    def in_term_transition?
      @current != @sis_current_term
    end

    def self.legacy_group(terms=nil)
      terms ||= self.fetch.campus.values
      terms = terms.to_a
      sisedo_terms, legacy_terms = [], []
      if terms.count > 0
        grouped = terms.group_by &:legacy?
        legacy_terms = grouped[true]
        sisedo_terms = grouped[false]
      end
      return {:legacy => legacy_terms, :sisedo => sisedo_terms} if Settings.features.allow_legacy_fallback
      {:legacy => nil, :sisedo => terms}
    end

  end
end
