module MyAcademics
  class MyStandings < UserSpecificModel
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      academic_standings = get_academic_standings
      parsed_standings = parse_standings(academic_standings)
      {
        feed: {
          currentStandings: parsed_standings[:current_standings],
          standingsHistory: parsed_standings[:standings_history]
        }
      }
    end

    def student_empl_id
      User::Identifiers.lookup_campus_solutions_id @uid
    end

    def get_academic_standings
      academic_standings = EdoOracle::Queries.get_academic_standings(student_empl_id)
      academic_standings ||= []
    end

    def parse_standings(academic_standings)
      parsed_standings = empty_standings
      current_standing = get_latest_current_standing(academic_standings)
      return parsed_standings unless current_standing
      # Its possible to have more than one current standing with same term and action date
      academic_standings.each do |standing|
        if standing['term_id'] == current_standing['term_id'] && standing['action_date'] == current_standing['action_date']
          parsed_standings[:current_standings].push(parse_standing(standing)) unless parsed_standings[:current_standings].any?
        else
          parsed_standings[:standings_history].push(parse_standing(standing))
        end
      end
      parsed_standings
    end

    def empty_standings
      {
        current_standings: [],
        standings_history: []
      }
    end

    def parse_standing(standing)
      term = Berkeley::TermCodes.from_edo_id(standing['term_id'])
      {
        acadStandingStatus: standing['acad_standing_status'],
        acadStandingStatusDescr: standing['acad_standing_status_descr'],
        acadStandingActionDescr: standing['acad_standing_action_descr'],
        termId: standing['term_id'],
        actionDate: Concerns::AcademicsModule.cast_utc_to_pacific(standing['action_date']),
        termName: Berkeley::TermCodes.to_english(term[:term_yr], term[:term_cd])
      }
    end

    def get_latest_current_standing(academic_standings)
      return nil unless academic_standings.any?
      academic_standings.sort_by!{|s| [s['term_id'], s['action_date']]}.reverse!
      academic_standings[0]
    end

  end
end
