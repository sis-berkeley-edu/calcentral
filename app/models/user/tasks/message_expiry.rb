module User
  module Tasks
    class MessageExpiry
      def self.expire(uid)
        User::Tasks::AgreementsFeed.expire(uid)
        User::Tasks::ChecklistFeed.expire(uid)
        User::Tasks::WebMessageFeed.expire(uid)
        MyAcademics::MyHolds.expire(uid)
        MyAcademics::MyAcademicStatus.expire(uid)
        MyAcademics::ClassEnrollments.expire(uid)
        FinancialAid::MyFinaidProfile.expire(uid)
        MyActivities::Merged.expire(uid)
      end
    end
  end
end
