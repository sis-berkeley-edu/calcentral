module MyRegistrations
  class Statuses < UserSpecificModel

    include CancellationNonPaymentModule
    include RegistrationsModule
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include ClassLogger

    def get_feed_internal
      {
        registrations: get_registration_statuses
      }
    end

    private

    def get_registration_statuses
      match_terms(registrations, terms).tap do |term_registrations|
        match_positive_indicators(positive_service_indicators, term_registrations)
        filter_invalid_registrations term_registrations
        set_reg_messaging term_registrations
        reduce_term_registrations term_registrations
        set_cnp_flags term_registrations
        set_cnp_messaging term_registrations
      end
    end

    def match_terms(registrations, terms)
      # initialize a map of terms and their registrations
      term_reg_map = {}.tap do |map|
        terms.each_value do |term|
          map[term[:id]] = {registrations: [], termFlags: term } unless (term.nil? || map.has_key?(term[:id]))
        end
      end

      # iterate through the registrations array and push to term_reg_map if there is an id match
      registrations.each do |registration|
        reg_term = registration['term']
        next unless term_reg_map.has_key?(reg_term['id'])

        registration[:isSummer] = Berkeley::TermCodes.edo_id_is_summer?(reg_term['id'])
        registration[:termFlags] = term_reg_map[reg_term['id']][:termFlags]
        registration['term']['name'] = Berkeley::TermCodes.normalized_english reg_term['name']
        term_reg_map[reg_term['id']][:registrations].push(registration)
      end

      # remove term flag data from our registrations map, linking each term to an array of reg objects
      term_reg_map = term_reg_map.transform_values { |term| term[:registrations] }

      # remove any term keys with no registration
      term_reg_map.delete_if { |term, registrations| registrations.empty? }
    end

    def terms
      terms = {}
      # current, running, and sis_current_term can all potentially be different depending on where we are in the academic year.
      # So, we grab all of them in case of term transitions.
      [:current, :running, :sis_current_term, :next, :future].each do |term_method|
        if (term = berkeley_terms.send term_method)
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
    end

    def positive_service_indicators
      positive_indicators = []
      student_attributes.each do |attribute|
        positive_indicators.push(attribute) if is_positive_service_indicator? attribute
      end
      positive_indicators.each do |indicator|
        check_indicator_dates indicator
      end
      positive_indicators
    end

    def find_message_by_number(message_nbr)
      registration_messages.find do |message|
        message.try(:[], :messageNbr).to_i == message_nbr
      end.try(:[], :descrlong)
    end

    def reg_explanations
      @explanations ||= {}.tap do |explanations|
        explanations.merge!({
          notOfficiallyRegistered:  find_message_by_number(100),
          cnpNotificationUndergrad: find_message_by_number(101),
          feesUnpaidGrad:           find_message_by_number(102),
          cnpWarningUndergrad:      find_message_by_number(103),
          cnpWarningGrad:           find_message_by_number(104),
          notEnrolledUndergrad:     find_message_by_number(105),
          notEnrolledGrad:          find_message_by_number(106),
          registeredSummerUgrd:     'You are officially registered for this term.',
          notRegisteredSummerUgrd:  'You are not officially registered for this term.'
        })
      end
    end

    def set_term_flags(term)
      current_date = Settings.terms.fake_now || DateTime.now
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

    def berkeley_terms
      @berkeley_terms ||= Berkeley::Terms.fetch
    end

    def student_attributes
      @student_attributes ||= HubEdos::V1::StudentAttributes.new(user_id: @uid).get
      @student_attributes.try(:[], :feed).try(:[], 'student').try(:[], 'studentAttributes') || []
    end

    def registrations
      @registrations ||= HubEdos::V1::Registrations.new(user_id: @uid).get
      @registrations.try(:[], :feed).try(:[], 'registrations') || []
    end

    def registration_messages
      @reg_messages ||= CampusSolutions::EnrollmentVerificationMessages.new().get
      @reg_messages[:feed][:root][:getMessageCatDefn] || []
    end

  end
end
