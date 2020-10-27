FactoryBot.define do
  factory :user_auth, class: "User::Auth" do
    sequence(:uid) { |n| n }

    active { true }

    factory :viewer_auth do
      is_viewer { true }
    end

    factory :author_auth do
      is_author { true }
    end

    factory :superuser_auth do
      is_superuser { true }
    end
  end
end
