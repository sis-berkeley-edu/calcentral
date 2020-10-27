FactoryBot.define do
  factory :service_alert, class: "ServiceAlert" do
    title { "CalCentral is the Bees Knees" }
    body { "<p>Also, we'll have to be down for an upgrade on Sunday</p>" }
    publication_date { "2020-10-04" }
  end
end
