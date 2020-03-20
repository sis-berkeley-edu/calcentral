module User
  module Tasks
    class Expiry
      ENF::Processor.instance.register("sis:student:checklist", self)
      ENF::Processor.instance.register("sis:student:messages", self)

      def self.call(message)
        uid = message.student_uid

        ::CampusSolutions::MyChecklist.expire(uid)
        ::MyTasks::Merged.expire(uid)
        ::CampusSolutions::Sir::SirStatuses.expire(uid)

        ::User::Tasks::AgreementsFeed.expire(uid)
        ::User::Tasks::ChecklistFeed.expire(uid)
        ::MyAcademics::MyHolds.expire(uid)
        ::MyAcademics::MyAcademicStatus.expire(uid)
        ::MyAcademics::ClassEnrollments.expire(uid)
        ::FinancialAid::MyFinaidProfile.expire(uid)
        ::MyActivities::Merged.expire(uid)
      end
    end
  end
end
