module MyAcademics
  module Grading
    class Period
      attr_accessor :start_date
      attr_accessor :due_date

      def initialize(start_date, due_date)
        self.start_date = start_date
        self.due_date = due_date
      end

      def ==(other)
        self.start_date == other.start_date && self.due_date == other.due_date
      end

      def formatted_date(date)
        current_date = Settings.terms.fake_now || Cache::CacheableDateTime.new(DateTime.now)
        return nil if date.blank?
        return date.to_date.strftime('%b %d') if current_date.year == date.to_date.year
        date.to_date.strftime('%b %d, %Y')
      end

      def formatted_start_date
        formatted_date(self.start_date)
      end

      def formatted_due_date
        formatted_date(self.due_date)
      end
    end
  end
end
