module MyRegistrations
  module SharedHelpers
    extend self

    CAREERS = {
      grad:      'GRAD',
      law:       'LAW',
      extension: 'UCBX',
      undergrad: 'UGRD'
    }
    UGRD_SUMMARIES = {
      registered:    'Officially Registered',
      notRegistered: 'Not Officially Registered',
      notEnrolled:   'Not Enrolled'
    }

    def extract_indicator_message(term, indicator_type)
      term.try(:[], :positiveIndicators).find do |indicator|
        indicator.try(:[], 'type').try(:[], 'code') == indicator_type
      end.try(:[], 'reason').try(:[], 'formalDescription')
    end

    def get_term_flag(term, flag)
      term.try(:[], :termFlags).try(:[], flag)
    end

    def get_term_career(term)
      term.try(:[], 'academicCareer').try(:[], 'code')
    end

    def term_includes_indicator?(term, indicator_type)
      !!term.try(:[], :positiveIndicators).find do |indicator|
        indicator.try(:[], 'type').try(:[], 'code') == indicator_type
      end
    end

  end
end
