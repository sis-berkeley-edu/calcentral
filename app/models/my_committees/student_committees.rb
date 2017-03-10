module MyCommittees
  class StudentCommittees

    include CommitteesModule
    include ClassLogger

    def merge(feed)
      feed.merge! get_feed
    end

    def get_feed
      result = {
        studentCommittees: [],
        committeeRequestChangeLink: fetch_link('UC_CX_GT_AAQEAPPLIC_ADD')
      }
      feed = CampusSolutions::StudentCommittees.new(user_id: @uid).get[:feed]

      if feed && (cs_committees = feed[:ucSrStudentCommittee][:studentCommittees])
        result[:studentCommittees] = parse_cs_student_committees cs_committees
      end
      result
    end

    def parse_cs_student_committees (cs_committees)
      cs_committees.compact!
      committees_result = []
      cs_committees.try(:each) do |cs_committee|
        remove_inactive_members(cs_committee)
        committee = parse_cs_committee(cs_committee)
        committee[:isActive] = is_active?(cs_committee)
        committees_result << committee
      end
      committees_result.compact
    end

    def is_active?(cs_committee)
      cs_committee.try(:[], :committeeFinishingMilestoneComplete) != 'Y'
    end

    def parse_cs_milestone_attempts(cs_committee)
      attempts = cs_committee[:studentMilestoneAttempts].try(:map) do |attempt|
        parse_cs_milestone_attempt(attempt)
      end
      return [] unless attempts
      attempts.try(:sort_by) do |attempt|
        attempt[:sequenceNumber]
      end.last(1)
    end

    def format_milestone_attempt(milestone_attempt)
      if first_attempt_exam_passed?(milestone_attempt)
        "#{milestone_attempt[:result]} #{milestone_attempt[:date]}"
      else
        "Exam #{milestone_attempt[:sequenceNumber]}: #{milestone_attempt[:result]} #{milestone_attempt[:date]}"
      end
    end

    def first_attempt_exam_passed?(milestone_attempt)
      milestone_attempt[:sequenceNumber] === 1 && milestone_attempt[:result] == Berkeley::GraduateMilestones::QE_STATUS_PASSED
    end

    def remove_inactive_members(cs_committee)
      cs_committee[:committeeMembers].try(:reject!) do |member|
        inactive?(member)
      end
    end

    def inactive?(committee_member)
      inactive = false;
      begin
        inactive = Time.zone.parse(committee_member[:memberEndDate].to_s).to_datetime.try(:past?)
      rescue
        logger.error "Bad Format for committee member end date; Class #{self.class.name} feed, uid = #{@uid}"
      end
      inactive
    end

  end
end
