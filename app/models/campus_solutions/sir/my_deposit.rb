module CampusSolutions
  module Sir
    class MyDeposit < UserSpecificModel

      include ClassLogger

      def get_feed
        logger.debug "User #{@uid}; aid adm_appl_nbr #{@options[:adm_appl_nbr]}"
        Deposit.new({user_id: @uid, adm_appl_nbr: @options[:adm_appl_nbr]}).get
      end

    end
  end
end
