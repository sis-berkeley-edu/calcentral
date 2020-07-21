module MyRegistrations
  class PositiveServiceIndicators
    include ClassLogger

    def initialize(uid)
      @uid = uid
    end

    def get
      positive_indicators = []
      student_attributes.each do |attribute|
        if is_positive_service_indicator?(attribute)
          positive_indicators.push(attribute)
          check_indicator_dates(attribute)
        end
      end
      positive_indicators
    end

    def student_attributes
      @student_attributes ||= HubEdos::StudentApi::V2::Feeds::StudentAttributes.new(user_id: @uid).get
      @student_attributes.try(:[], :feed).try(:[], 'studentAttributes') || []
    end

    def check_indicator_dates(indicator)
      term_start = indicator.try(:[], 'fromTerm').try(:[], 'id').to_i
      term_end = indicator.try(:[], 'toTerm').try(:[], 'id').to_i
      if term_start != term_end
        indicator_type = indicator.try(:[], 'type').try(:[], 'code')
        logger.warn "Positive service indicator spanning multiple terms found for #{@uid}. Indicator: #{indicator_type}, termStart ID: #{term_start}, termEnd ID: #{term_end}. Using termStart ID to parse registration status."
      end
    end

    def is_positive_service_indicator?(attribute)
      attribute.try(:[], 'type').try(:[], 'code').try(:start_with?, '+')
    end
  end
end
