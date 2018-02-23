module CampusSolutions
  class MyTermsAndConditions < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::TermsAndConditions.new({user_id: @uid, params: params})
      ChecklistDataExpiry.expire @uid
      FinancialAidExpiry.expire @uid
      proxy.post
    end

  end
end
