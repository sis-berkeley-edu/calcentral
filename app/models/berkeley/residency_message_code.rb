module Berkeley
  module ResidencyMessageCode
    extend self
    include ClassLogger

    def residency_message_code(slr_status, residency_status, tuition_exception)
      slr_status.strip! if slr_status
      residency_status.strip! if residency_status
      tuition_exception.strip! if tuition_exception
      message_code = case residency_status
        when nil, ''  # Not submitted
          '2000' unless ['A', 'S', 'R'].include? slr_status   # Only for Pending residency
        when 'PEND' # Pending
          case slr_status
            when 'A', 'S' # Awaiting Documents, Submitted
              '2001'
            when 'R'  # Documents Received
              '2002'
            else
              '2000'
          end
        when 'RES'  # Resident
          case tuition_exception
            when nil, '' # Submitted, completed, nothing more to say
              '2003'
            when 'R8', 'RP', 'RB' # Credentialed Public School Emp, Dependent Deceased Law Enf/FF, Grad Bureau Indian Aff Sch
              '2006'
            when 'RD', 'RDO', 'RDRA'  # Attorney Waiver, DACA Students not CA or AB 540, Pending I-485 & AB 540 Eligible
              '2008'
            when 'R9', 'R6' # Chula Vista Athlete, Dependent of CA Res Parent
              '2011'
          end
        when 'NON'  # Non-resident
          case tuition_exception
            when nil, '' # Submitted, completed, nothing more to say
              '2004'
            when 'RA', 'RV' # AB 540, Veteran/Dependent of Veteran
              '2005'
            when 'RP' # Dependent Deceased Law Enf/FF
              '2007'
            when 'RD', 'RL', 'RF', 'RDRA', 'RE' # Attorney Waiver, Dep of UC Emp Outside CA, Faculty Spouse or Dependent, Pending I-485 & AB 540 Eligible, UC Employee Outside CA
              '2009'
            when 'RM' # Military Member/Dep/Spouse
              '2010'
          end
      end
      if message_code.nil?
        logger.warn "Cannot determine message code for residency '#{residency_status}', SLR '#{slr_status}', tuition exception '#{tuition_exception}'"
        nil
      else
        message_code
      end
    end
  end
end
