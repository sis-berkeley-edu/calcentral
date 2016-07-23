module MyRegistrations
  class MyRegistrations < UserSpecificModel

    include Berkeley::UserRoles
    include Cache::CachedFeed
    include Cache::JsonAddedCacher
    include Cache::UserCacheExpiry

    def get_feed_internal
      registrations = get_registrations
      terms = get_terms
      {
        affiliations: registrations['affiliations'] || [],
        terms: terms,
        registrations: match_terms(registrations['registrations'], terms)
      }
    end

    def get_registrations
      registrations = HubEdos::Registrations.new(user_id: @uid).get
      registrations[:feed] || []
    end

    def get_terms
      berkeley_terms = Berkeley::Terms.fetch
      terms = {}
      # ':previous' and ':grading_in_progress' methods are not included here because Campus::Oracle does not keep information prior to the current term.
      # These methods should be added in Spring 2017, once CS will start sending back Fall 2016 data.
      [:current, :running, :sis_current_term, :next, :future].each do |term_method|
        term = berkeley_terms.send term_method
        if term
          terms[term_method] = {id: term.campus_solutions_id, name: term.to_english}
          # For 'current' and 'next' terms, we need the date of start and end of instruction to determine CNP status
          if (term_method == :current || term_method == :next)
            temporal_position = term_method == :current ? HubTerm::Proxy::CURRENT_TERM : HubTerm::Proxy::NEXT_TERM
            cs_feed = HubTerm::Proxy.new(temporal_position: temporal_position).get_term
            terms[term_method] = terms[term_method].merge(
              {
                classesStart: term_start(cs_feed),
                end: term_end(cs_feed),
                endDropAdd: term_end_drop_add(cs_feed)
              }
            )
            terms[term_method] = set_term_flags(terms[term_method])
          end
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
        # Financial Aid disbursement is used in CNP notification.  This will be 8 days before start of instruction in Fall 2016,
        # but this should be changed to 9 days before start of instruction post-Fall 2016.
        pastFinancialDisbursement: current_date >= (term[:classesStart] - 8)
        })
    end

    private

    # Match registration terms with Berkeley::Terms-defined terms.
    def match_terms(registrations, terms)
      legacy_cutoff = Berkeley::TermCodes.slug_to_edo_id(Settings.terms.legacy_cutoff)
      matched_terms = {}
      terms.each do |key, value|
        next if (value.nil? || matched_terms[value[:id]].present?)
        # Array format due to the possibility of a single term containing multiple academic career registrations
        term_id = value[:id]
        term_registrations = []
        # If the term is less than or equal to Settings.terms.legacy_cutoff, parse it as we would a legacy term.
        if (term_id.to_i <= legacy_cutoff.to_i)
          term_registrations.push parse_legacy_term(key, term_id, value[:name])
        elsif registrations.present?
          registrations.each do |registration|
            if (term_id == registration['term']['id'])
              term_registrations.push(registration)
            end
          end
        end
        matched_terms[term_id] = term_registrations if term_registrations.present?
      end
      matched_terms
    end

    def parse_legacy_term(term_name, term_id, term_english)
      term_code = Berkeley::TermCodes.from_edo_id(term_id)
      result = CampusOracle::Queries.get_person_attributes_with_term_reg(@uid, term_code[:term_yr], term_code[:term_cd])
      return if result.nil?
      if result
        result[:reg_status] = Notifications::RegStatusTranslator.new.translate_for_feed result['reg_status_cd']
        result[:reg_status][:education_level] = Notifications::EducLevelTranslator.new.translate result['educ_level']
        result[:reg_status].merge! Berkeley::SpecialRegistrationProgram.attributes_from_code(result['reg_special_pgm_cd'])
        result[:roles] = roles_from_campus_row result
      end
      response = {
        is_legacy: true,
        reg_status: result[:reg_status],
        roles: result[:roles]
      }

      # This logic is only used for transition terms, as shown in MyBadges::StudentInfo
      if (term_transition? && result[:reg_status][:summary] != 'Registered')
        response[:reg_status] = {
            code: " ",
            summary: "Not registered for #{term_english}",
            explanation: nil,
            needsAction: false
        }
      end

      if (term_name == :current || term_name == :running)
        result[:reg_status][:transitionTerm] = true if term_transition?
      end

      HashConverter.camelize response
    end

    def term_start(cs_feed)
      Berkeley::Term.new.from_cs_api(cs_feed).classes_start
    end

    def term_end(cs_feed)
      Berkeley::Term.new.from_cs_api(cs_feed).end
    end

    def term_end_drop_add(cs_feed)
      Berkeley::Term.new.from_cs_api(cs_feed).end_drop_add
    end

    def term_transition?
      Berkeley::Terms.fetch.in_term_transition?
    end

  end
end
