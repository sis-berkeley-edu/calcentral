module MyCommittees
  class FacultyCommittees

    include CommitteesModule
    include ClassLogger

    def merge(feed)
      feed.merge! get_feed
    end

    def get_feed
      result = {
        facultyCommittees: {
          active: [],
          completed: []
        }
      }
      feed = CampusSolutions::FacultyCommittees.new(user_id: @uid).get.try(:[], :feed)
      if feed && (cs_committees = feed[:ucSrFacultyCommittee].try(:[], :facultyCommittees))
        @emplid = feed[:ucSrFacultyCommittee].try(:[], :emplid)
        result[:facultyCommittees] = parse_cs_faculty_committees(cs_committees , result[:facultyCommittees])
      end
      result
    end

    def parse_cs_faculty_committees (cs_committees, committees_result)
      cs_committees.compact!
      cs_committees.try(:each) do |cs_committee|
        faculty_committee = parse_cs_committee(cs_committee)
        merge_faculty_specific_data(cs_committee, faculty_committee)
        if member_active? faculty_committee
          committees_result[:active] << faculty_committee
        else
          committees_result[:completed] << faculty_committee
        end
      end
      committees_result[:completed] = sort_committees_by_svc(committees_result[:completed])
      committees_result[:active] = sort_committees_by_svc(committees_result[:active])
      committees_result
    end

    def merge_faculty_specific_data(cs_committee, faculty_committee)
      faculty_committee.merge! milestoneAttempts: parse_cs_qualifying_exam_attempts(cs_committee)
      faculty_committee.merge! student: parse_cs_committee_student(cs_committee)
      faculty_committee.merge! parse_cs_faculty_committee_svc(cs_committee)
    end

    def set_committee_status(cs_committee, committee)
      if qualifying_exam?(cs_committee)
        committee[:statusIcon] = determine_qualifying_exam_status_icon(committee)
        committee[:statusMessage] = determine_qualifying_exam_status_message(cs_committee)
      elsif !is_active?(cs_committee) && cs_committee[:studentFilingDate]
        committee[:statusIcon] = STATUS_ICON_SUCCESS
        committee[:statusMessage] = "Filing Date: #{format_date(cs_committee[:studentFilingDate])}"
      elsif (advanced_date = determine_advanced_date(cs_committee))
        committee[:statusMessage] = "Advanced: #{format_date(advanced_date)}"
      end
    end

    def determine_qualifying_exam_status_icon(committee)
      latest_attempt = committee.try(:[], :milestoneAttempts).try(:first)
      return '' unless latest_attempt
      if latest_attempt.try(:[], :result) == Berkeley::GraduateMilestones::QE_RESULTS_STATUS_PASSED
        STATUS_ICON_SUCCESS
      elsif latest_attempt.try(:[], :sequenceNumber) === 1
        STATUS_ICON_WARN
      else
        STATUS_ICON_FAIL
      end
    end

    def determine_advanced_date(cs_committee)
      if (advanced_date = cs_committee[:studentAdvancedDate]).blank?
        advanced_date = latest_milestone_attempt(cs_committee).try(:[], :attemptDate)
      end
      advanced_date
    end

    def latest_milestone_attempt(cs_committee)
      cs_committee.try(:[], :studentApprovalMilestoneAttempts).try(:sort_by!) do |attempt|
        attempt.try(:[], :attemptNbr)
      end.try(:last)
    end

    def parse_cs_qualifying_exam_attempts(cs_committee)
      qualifying_exam_attempts = []
      if qualifying_exam?(cs_committee)
        qualifying_exam_attempts = parse_cs_milestone_attempts(cs_committee)
      end
      qualifying_exam_attempts
    end

    def parse_cs_milestone_attempts(cs_committee)
      attempts = cs_committee[:studentApprovalMilestoneAttempts].try(:map) do |attempt|
        parse_cs_milestone_attempt(attempt)
      end
      attempts.try(:sort_by) do |attempt|
        attempt[:sequenceNumber]
      end.try(:reverse)
    end

    def parse_cs_milestone_attempt(cs_milestone_attempt)
      milestone_attempt = {
        sequenceNumber: cs_milestone_attempt[:attemptNbr].to_i,
        date: format_date(cs_milestone_attempt[:attemptDate]),
        result: Berkeley::GraduateMilestones.get_status(cs_milestone_attempt[:attemptStatus], Berkeley::GraduateMilestones::QE_RESULTS_MILESTONE)
      }
      milestone_attempt[:display] = format_milestone_attempt(milestone_attempt)
      milestone_attempt
    end

    def format_milestone_attempt(milestone_attempt)
      "Exam #{milestone_attempt[:sequenceNumber]}: #{milestone_attempt[:result]} #{milestone_attempt[:date]}"
    end

    def parse_cs_committee_member (cs_committee_member)
      {
        name: "#{cs_committee_member[:memberNameFirst]} #{cs_committee_member[:memberNameLast]}",
        email: cs_committee_member[:memberEmail],
        photo: committee_member_photo_url(cs_committee_member),
        primaryDepartment:  cs_committee_member[:memberDeptDescr]
      }
    end

    def sort_committees_by_svc(cs_committees)
      cs_committees.try(:sort_by) do |committee|
        # set the enddate to 9999-99-99 to allow for sort_by to do string comparison.
        # sort_by does not allow for us to change the sorting logic based on nil values in the block.
        # we can only pass back a default value to be used in sorting algorithm beyond the code block.
        # sort_by is more efficient than sort when performing operations on sorted variable.
        [committee[:csMemberEndDate] || '9999-99-99', committee[:csMemberStartDate] || '']
      end.try(:reverse)
    end

    def parse_cs_committee_student (cs_committee)
      {
        name: "#{cs_committee[:studentNameFirst]} #{cs_committee[:studentNameLast]}",
        email: cs_committee[:studentEmail],
        photo: committee_student_photo_url(cs_committee)
      }
    end

    def parse_cs_faculty_committee_svc(cs_committee)
      current_user_member = cs_committee.try(:[], :committeeMembers).try(:find) do |member|
        member.try(:[], :memberEmplid) == @emplid
      end
      {
        serviceRange: format_member_service_dates(current_user_member),
        csMemberEndDate: current_user_member.try(:[], :memberEndDate),
        csMemberStartDate: current_user_member.try(:[], :memberStartDate)
      }
    end
  end
end
