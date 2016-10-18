module DegreeProgress
  module MilestonesModule

    CAREER_LAW = 'LAW'
    ACAD_PROG_CODE_LACAD = 'LACAD'

    def process(response)
      degree_progress = response.try(:[], :feed).try(:[], :ucAaProgress).try(:[], :progresses)
      massage_progresses(degree_progress)
    end

    def massage_progresses(degree_progress)
      result = []
      if !!degree_progress
        degree_progress.each do |progress|
          if should_exclude progress
            next
          end

          result.push(progress).last.tap do |prog|
            massage_requirements prog
          end
        end
      end
      result
    end

    def massage_requirements(progress)
      requirements = normalize(progress.fetch(:requirements))
      merged_requirements = merge(requirements)
      progress[:requirements] = merged_requirements
    end

    def should_exclude(progress)
      CAREER_LAW == progress[:acadCareer] && ACAD_PROG_CODE_LACAD != progress[:acadProgCode]
    end

    def normalize(requirements)
      requirements.map! do |requirement|
        name = Berkeley::DegreeProgress.get_description(requirement[:code])
        if name
          requirement[:name] = name
          requirement[:status] = Berkeley::DegreeProgress.get_status(requirement[:status])
          requirement
        end
      end
      requirements.compact
    end

    def merge(requirements)
      merge_candidates = []
      merged_requirements = []

      requirements.each do |requirement|
        if is_merge_candidate requirement
          merge_candidates.push requirement
        else
          merged_requirements.push requirement
        end
      end

      if merge_candidates.length > 1
        first = find_first merge_candidates
        first[:name] = Berkeley::DegreeProgress.get_merged_description
        merged_requirements.unshift(first)
      elsif merge_candidates.length === 1
        merged_requirements.unshift(merge_candidates.first)
      end
      merged_requirements
    end

    def is_merge_candidate(requirement)
      is_advancement_to_candidacy = %w(AAGADVMAS1 AAGADVMAS2).include? requirement[:code]
      is_incomplete = requirement[:date].blank?

      is_incomplete && is_advancement_to_candidacy
    end

    def find_first(requirements)
      requirements.min do |first, second|
        first[:number] <=> second[:number]
      end
    end
  end
end
