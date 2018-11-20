module MyAcademics
  class MyStandings < UserSpecificModel
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      academic_standings = get_academic_standings
      parsed_standings = parse_standings(academic_standings)
      message = CampusSolutions::MessageCatalog.new(message_set_nbr: 28000, message_nbr: 210).get
      {
        feed: {
          currentStandings: parsed_standings[:current_standings],
          standingsHistory: parsed_standings[:standings_history],
          learnMoreMessage: message.try(:[], :feed).try(:[], :root).try(:[], :getMessageCatDefn).try(:[], :descrlong)
        }
      }
    end

    def student_empl_id
      User::Identifiers.lookup_campus_solutions_id @uid
    end

    def get_academic_standings
      academic_standings = EdoOracle::Queries.get_academic_standings(student_empl_id) if Settings.features.standings
      academic_standings ||= []
    end

    def parse_standings(academic_standings)
      parsed_standings = empty_standings
      current_standing = get_latest_current_standing(academic_standings)
      return parsed_standings unless current_standing
      # Its possible to have more than one standing with same term and action date
      # Only use the latest one for each term.
      processed_term = []
      academic_standings.each do |standing|
        if standing['term_id'] == current_standing['term_id'] && standing['action_date'] == current_standing['action_date']
          parsed_standings[:current_standings].push(parse_standing(standing)) unless parsed_standings[:current_standings].any?
          processed_term.push standing['term_id']
        else
          unless processed_term.include? standing['term_id']
            parsed_standings[:standings_history].push(parse_standing(standing))
            processed_term.push standing['term_id']
          end
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
      Concerns::AcademicsModule.standings_info(standing)
    end

    def get_latest_current_standing(academic_standings)
      return nil unless academic_standings.any?
      academic_standings.sort_by!{|s| [s['term_id'], s['action_date']]}.reverse!
      academic_standings[0]
    end

  end
end
