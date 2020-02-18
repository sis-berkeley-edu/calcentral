module User
  class Current
    attr_reader :uid

    include User::BCourses::Concern
    include User::Notifications::Concern
    include User::Tasks::Concern
    include User::Webcasts::Concern

    def initialize(uid)
      @uid = uid
    end

    def campus_solutions_id
      @campus_solutions_id ||= User::Identifiers.lookup_campus_solutions_id(uid)
    end

    def billing_items
      @billing_items ||= User::Finances::BillingItems.new(self)
    end

    def billing_summary
      @billing_summary ||= User::Finances::BillingSummary.new(self)
    end

    def holds
      @holds ||= User::Academics::Holds.new(self)
    end

    def registrations
      @registrations ||= User::Academics::Registrations.new(self)
    end

    def user_attributes
      @user_attributes ||= User::UserAttributes.new(self)
    end

    def student_attributes
      @student_attributes ||= User::Academics::StudentAttributes.new(self)
    end

    def term_registrations
      @term_registrations ||= User::Academics::TermRegistrations.new(self)
    end

    def status_and_holds
      @status_and_holds ||= User::Academics::StatusAndHolds.new(self)
    end

    def student_groups
      @student_groups ||= User::Academics::StudentGroups.new(self)
    end

    def matriculated?
      !affiliations.matriculated_but_excluded? && affiliations.not_registered?
    end

    private

    def affiliations
      @affiliations ||= User::Affiliations.new(self)
    end
  end
end
