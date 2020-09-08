module User
  module Cards
    class EnrollmentExpiry < ::ENF::Handler
      ENF::Processor.instance.register("sis:student:serviceindicator", self)
      ENF::Processor.instance.register("sis:student:messages", self)

      def self.call(enf_message)
        self.new(enf_message).expire
      end

      def expire
        uids.each do |uid|
          ::MyAcademics::ClassEnrollments.expire(uid)
          ::MyAcademics::MyHolds.expire(uid)
          ::MyAcademics::MyAcademicStatus.expire(uid)

          ::HubEdos::StudentApi::V2::Feeds::Registrations.expire(uid)
          ::HubEdos::StudentApi::V2::Feeds::StudentAttributes.expire(uid)
          ::HubEdos::StudentApi::V2::Feeds::AcademicStatuses.expire(uid)
        end
      end
    end
  end
end
