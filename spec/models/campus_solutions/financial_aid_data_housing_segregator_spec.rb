describe CampusSolutions::FinancialAidDataHousingSegregator do
  let(:user_id) { random_id }
  let(:aid_year) { '2018' }
  let(:raw_feed) { CampusSolutions::FinancialAidData.new(fake: true, user_id: user_id, aid_year: aid_year).get }
  it 'segregates housing data from status' do
    result = described_class.segregate(raw_feed)
    expect(result[:feed][:housing][:title]).to eq 'Housing'
    expect(result[:feed][:housing].has_key?(:values)).to eq true
    expect(result[:feed][:housing].has_key?(:link)).to eq true

    status_finaid_profile_category = result[:feed][:status][:categories].find do |category|
      category.try(:[], :title) == 'Financial Aid Profile'
    end
    housing_item = nil
    status_finaid_profile_category[:itemGroups].each do |itemGroup|
      itemGroup.each do |item|
        if item.try(:[], :title) == 'Housing'
          housing_item = item
        end
        break if housing_item.present?
      end
      break if housing_item.present?
    end
    expect(housing_item).to eq nil
  end
end
