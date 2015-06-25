FactoryGirl.define do
  factory :user do
    email 'test@test.com'
    provider 'developer'
    uid '1234'
    password 'password'
    password_confirmation 'password'
    accepted_terms true
    trait :sign_in do
      name Faker::Name.name
      premium_subscription false
    end
    trait :update do
      name Faker::Name.name
    end
    trait :update_teacher do
      name Faker::Name.name
    end
  end
end
