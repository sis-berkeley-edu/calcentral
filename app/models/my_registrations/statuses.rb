module MyRegistrations
  class Statuses < UserSpecificModel

    include RegistrationsModule
    include Berkeley::UserRoles
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include ClassLogger

    PRIORITIZED_CAREERS = ['LAW', 'GRAD', 'UGRD', 'UCBX']

    def get_feed_internal
      {
        terms: flagged_terms,
        registrations: get_registration_statuses
      }
    end

    private

    def get_registration_statuses
      match_terms(registrations, flagged_terms).tap do |term_registrations|
        match_positive_indicators term_registrations
        set_summer_flags term_registrations
        set_regstatus_flags term_registrations
        set_regstatus_messaging term_registrations
        set_cnp_flags term_registrations
        set_cnp_messaging term_registrations
      end
    end

    # Match registration terms with Berkeley::Terms-defined terms.
    def match_terms(registrations = [], terms = [])
      matched_terms = {}
      terms.each do |term_key, term_value|
        next if (term_value.nil? || matched_terms[term_value[:id]].present?)
        term_id = term_value[:id]
        # Array format due to the possibility of a single term containing multiple academic career registrations
        term_registrations = []
        registrations.to_a.each do |registration|
          if term_id == registration.try(:[], 'term').try(:[], 'id')
            registration[:termFlags] = term_value
            registration['term']['name'] = normalized_english registration['term']['name']
            term_registrations.push(registration)
          end
        end
        # If there is more than one career in a term, we prioritize them and only show the most relevant one.
        term_registration = find_relevant_career term_registrations
        matched_terms[term_id] = term_registration if term_registration.present?
      end
      matched_terms
    end

    # If a student is activated for more than one career within a term, we prioritize the careers
    # and only show the most relevant one.  Prioritization of careers follows the pattern of LAW -> GRAD -> UGRD
    def find_relevant_career(registrations)
      return nil if registrations.length == 0
      return registrations[0] if registrations.length == 1
      PRIORITIZED_CAREERS.each do |career|
        relevant_career = registrations.find do |registration|
          registration.try(:[], 'academicCareer').try(:[], 'code') == career
        end
        return relevant_career if relevant_career
      end
      nil
    end

    # Match positive service indicators from student attributes with their registration term.
    def match_positive_indicators(term_registrations = {})
      # Create a clone of the positive service indicators array, since we'll be altering it.
      pos_indicators = MyRegistrations::PositiveServiceIndicators.new(@uid).get.clone
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

    def flagged_terms
      @flagged_terms ||= MyRegistrations::FlaggedTerms.new.get
    end

    def registrations
      @registrations ||= HubEdos::StudentApi::V2::Feeds::Registrations.new(user_id: @uid).get
      @registrations.try(:[], :feed).try(:[], 'registrations') || []
    end
  end
end
