module MyAcademics
  module Grading
    class Session
      extend Cache::Cacheable

      attr_accessor :term_id
      attr_accessor :session_code
      attr_accessor :acad_career

      attr_accessor :midterm_period
      attr_accessor :final_period

      def self.get_session(term_id, acad_career_code, session_id = '1')
        all_sessions = self.fetch
        all_sessions.try(:[], term_id).try(:[], acad_career_code).try(:[], session_id)
      end

      def self.grading_term_present?(term_id)
        self.fetch.try(:keys).include? term_id
      end

      def self.fetch(options = {})
        smart_fetch_from_cache(force_write: options[:force]) do
          all_sessions
        end
      end

      def self.all_sessions
        grading_dates = {}
        EdoOracle::Queries.get_grading_dates.each do |edo_hash|
          options = {edo_hash: edo_hash}
          session = self.new(options)

          grading_dates[session.term_id] ||= {}
          grading_dates[session.term_id][session.acad_career] ||= {}
          grading_dates[session.term_id][session.acad_career][session.session_code] ||= session
        end
        grading_dates
      end

      def initialize(opts = {})
        if edo_hash = opts[:edo_hash]
          self.term_id = edo_hash.try(:[], 'term_id')
          self.session_code = edo_hash.try(:[], 'session_code')
          self.acad_career = edo_hash.try(:[], 'acad_career')

          self.midterm_period = MyAcademics::Grading::Period.new(edo_hash.try(:[], 'mid_term_begin_date'), edo_hash.try(:[], 'mid_term_end_date'))
          self.final_period = MyAcademics::Grading::Period.new(edo_hash.try(:[], 'final_begin_date'), edo_hash.try(:[], 'final_end_date'))
        end
      end
    end
  end
end
