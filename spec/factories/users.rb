FactoryBot.define do
  factory :user do
   sequence(:username) { |n| "TEST_NAME#{n}" }
   sequence(:email) { |n| "TEST#{n}@example.com" }
   password { "password" }
   password_confirmation { "password" }
  end
end
