module CampusSolutions
  # Used as temporary workaround pending API update in SISRP-37934
  module FinancialAidDataHousingSegregator

    def self.segregate(financial_aid_data)
      if status_categories = financial_aid_data.try(:[], :feed).try(:[], :status).try(:[], :categories)
        finaid_profile_category_index = get_finaid_profile_category_index(status_categories)
        finaid_profile_category = status_categories[finaid_profile_category_index]

        if profile_item_groups = finaid_profile_category.try(:[], :itemGroups)
          housing_item_group_index, housing_item_index = get_housing_item_indexes(profile_item_groups)
          if housing_item_group_index.present?
            # Remove itemGroup containing Housing item if present
            profile_category = financial_aid_data[:feed][:status][:categories][finaid_profile_category_index]
            segregated_housing_item_group = profile_category[:itemGroups].delete_at(housing_item_group_index)

            # Append item to 'housing' node
            financial_aid_data[:feed][:housing] = segregated_housing_item_group[housing_item_index]
          end
        end
      end
      financial_aid_data
    end

    # Identifies indexes for item group and item related to 'Housing'
    def self.get_housing_item_indexes(profile_item_groups)
      housing_item_index = nil
      housing_item_group_index = nil
      Array(profile_item_groups).each_with_index do |itemGroup, item_group_index|
        Array(itemGroup).each_with_index do |item, item_index|
          if item.try(:[], :title) == 'Housing'
            housing_item_group_index = item_group_index
            housing_item_index = item_index
            break
          end
        end
        break if housing_item_group_index.present?
      end
      return [housing_item_group_index, housing_item_index]
    end

    def self.get_finaid_profile_category_index(status_categories)
      finaid_profile_category_index = nil
      Array(status_categories).each_with_index do |category, category_index|
        if category.try(:[], :title) == 'Financial Aid Profile'
          finaid_profile_category_index = category_index
          break
        end
      end
      finaid_profile_category_index
    end
  end
end
