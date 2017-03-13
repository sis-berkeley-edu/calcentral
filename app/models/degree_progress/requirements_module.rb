module DegreeProgress
  module RequirementsModule
    include DatedFeed

    def process(response)
      degree_progress = response.try(:[], :feed).try(:[], :ucAaProgress)
      degree_progress[:progresses] = massage_progresses(degree_progress.try(:[], :progresses))
      degree_progress
    end

    def massage_progresses(progresses)
      result = []
      if progresses
        progresses.each do |progress|
          requirements = massage_requirements progress
          if requirements.blank?
            next
          end
          result.push(progress).last.tap do |prog|
            prog[:reportDate] = format_report_date prog.delete(:rptDate)
            prog[:requirements] = requirements
          end
        end
      end
      result
    end

    def massage_requirements(progress)
      requirements = progress.fetch(:requirements)
      result = []
      requirements.each do |requirement|
        result.push(normalize requirement) if should_include requirement
      end
      sort result
    end

    def format_report_date(report_date_unformatted)
      return nil if report_date_unformatted.blank?
      report_date_object = strptime_in_time_zone(report_date_unformatted, '%Y-%m-%d')
      format_date(report_date_object, '%b %e, %Y').try(:[], :dateString).to_s.squish
    end

    def should_include(requirement)
      Berkeley::DegreeProgressUndergrad.requirements_whitelist.include?(Integer(requirement[:code], 10)) unless requirement[:code].blank?
    rescue ArgumentError
      false
    end

    def normalize(requirement)
      requirement.clone.tap do |req|
        req[:name] = Berkeley::DegreeProgressUndergrad.get_description req[:code]
        req[:status] = Berkeley::DegreeProgressUndergrad.get_status(req[:status], req.delete(:inProgress))
      end
    end

    def sort(requirements)
      return requirements if requirements.blank?
      requirements.sort_by! do |req|
        Berkeley::DegreeProgressUndergrad.get_order(req[:code])
      end
      requirements
    end
  end
end
