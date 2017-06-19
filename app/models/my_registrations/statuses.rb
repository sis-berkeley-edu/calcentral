module MyRegistrations
  class Statuses < UserSpecificModel

    include RegistrationsModule
    include Berkeley::UserRoles
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include ClassLogger

    def get_feed_internal
      @terms = get_terms
      {
        terms: @terms,
        registrations: get_registration_statuses
      }
    end

    def regstatus_messages
      {
        notOfficiallyRegistered: find_message_by_number(100),
        cnpNotificationUndergrad: find_message_by_number(101),
        feesUnpaidGrad: find_message_by_number(102),
        cnpWarningUndergrad: find_message_by_number(103),
        cnpWarningGrad: find_message_by_number(104),
        notEnrolledUndergrad: find_message_by_number(105),
        notEnrolledGrad: find_message_by_number(106)
      }
    end

    private

    def get_registration_statuses
      match_terms(registrations, @terms).tap do |term_registrations|
        match_positive_indicators term_registrations
        set_summer_flags term_registrations
        set_regstatus_flags term_registrations
        set_regstatus_messaging term_registrations
        set_cnp_flags term_registrations
        set_cnp_messaging term_registrations
      end
    end

    def registration_messages
      @reg_messages ||= CampusSolutions::EnrollmentVerificationMessages.new().get
      @reg_messages.try(:[], :feed).try(:[], :root).try(:[], :getMessageCatDefn) || []
    end

    def find_message_by_number(message_nbr)
      registration_messages.find do |message|
        message.try(:[], :messageNbr).to_i == message_nbr
      end.try(:[], :descrlong)
    end

    def berkeley_terms
      @berkeley_terms ||= Berkeley::Terms.fetch
    end

    def registrations
      @registrations ||= HubEdos::Registrations.new(user_id: @uid).get
      @registrations.try(:[], :feed).try(:[], 'registrations') || []
    end

    def student_attributes
      @student_attributes ||= HubEdos::StudentAttributes.new(user_id: @uid).get
      @student_attributes.try(:[], :feed).try(:[], 'student').try(:[], 'studentAttributes') || []
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

    def get_terms
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

    # Match registration terms with Berkeley::Terms-defined terms.
    def match_terms(registrations, terms)
      matched_terms = {}
      terms.each do |term_key, term_value|
        next if (term_value.nil? || matched_terms[term_value[:id]].present?)
        term_id = term_value[:id]
        # Array format due to the possibility of a single term containing multiple academic career registrations
        term_registrations = []
        if registrations.present?
          registrations.each do |registration|
            if term_id == registration.try(:[], 'term').try(:[], 'id')
              registration[:termFlags] = term_value
              registration['term']['name'] = normalized_english registration['term']['name']
              term_registrations.push(registration)
            end
          end
        end
        # If there is more than one career in a term, we prioritize them and only show the most relevant one.
        term_registration = find_relevant_career term_registrations
        matched_terms[term_id] = term_registration if term_registration.present?
      end
      matched_terms
    end

    # Match positive service indicators from student attributes with their registration term.
    def match_positive_indicators(term_registrations)
      # Create a clone of the positive service indicators array, since we'll be altering it.
      pos_indicators = positive_service_indicators.clone
      term_registrations.each do |term_id, term_values|
        term_values[:positiveIndicators] = [].tap do |term_indicators|
          # Each indicator has a "fromTerm" and a "toTerm", but UC Berkeley usage of the positive service indicator is
          # term-specific, so these should always be the same.
          pos_indicators.delete_if do |indicator|
            if term_id.try(:to_i) == indicator.try(:[], 'fromTerm').try(:[], 'id').try(:to_i)
              term_indicators << indicator
              # Delete the indicator from our array so we don't have to process it again
              true
            end
          end
        end
      end
      term_registrations
    end

  end
end
