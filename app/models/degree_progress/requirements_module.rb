module DegreeProgress
  module RequirementsModule
    include Concerns::DatesAndTimes
    include Concerns::TransferCredit
    include DatedFeed
    include LinkFetcher

    def process(response)
      degree_progress = response.try(:[], :feed).try(:[], :ucAaProgress)
      degree_progress[:progresses] = massage_progresses(degree_progress.try(:[], :progresses))
      degree_progress[:transferCreditReviewDeadline] = is_pending_transfer_credit_review_deadline(student_empl_id) ? get_month(transfer_credit_review_deadline(student_empl_id)) : nil
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
            prog[:reportDate] = format_date_string prog.delete(:rptDate)
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
        result.push normalize(requirement, is_pending_transfer_credit_review_deadline(student_empl_id)) if should_include requirement
      end
      sort result
    end

    def format_date_string(date_unformatted)
      return nil if date_unformatted.blank?
      date_object = strptime_in_time_zone(date_unformatted, '%Y-%m-%d')
      pretty_date date_object
    end

    def pretty_date(date_object)
     format_date(date_object, '%b %e, %Y').try(:[], :dateString).to_s.squish
    end

    def should_include(requirement)
      Berkeley::DegreeProgressUndergrad.requirements_whitelist.include?(Integer(requirement[:code], 10)) unless requirement[:code].blank?
    rescue ArgumentError
      false
    end

    def normalize(requirement, is_pending_transfer_credit_review_deadline)
      requirement.clone.tap do |req|
        req[:name] = Berkeley::DegreeProgressUndergrad.get_description req[:code]
        req[:status] = Berkeley::DegreeProgressUndergrad.get_status(req[:status], req.delete(:inProgress), is_pending_transfer_credit_review_deadline)
      end
    end

    def sort(requirements)
      return requirements if requirements.blank?
      requirements.sort_by! do |req|
        Berkeley::DegreeProgressUndergrad.get_order(req[:code])
      end
      requirements
    end

    def student_empl_id
      User::Identifiers.lookup_campus_solutions_id @uid
    end

    def get_links
      links = {}
      links_config = [
        { feed_key: :academic_progress_report, cs_link_key: self.class::LINK_ID, cs_link_params: { :EMPLID => student_empl_id } }
      ]
      links_config.each do |setting|
        link = fetch_link setting[:cs_link_key], setting[:cs_link_params]
        links[setting[:feed_key]] = link unless link.blank?
      end
      links
    end
  end
end
