FactoryGirl.define do
  factory :user do
    email            'developers@example.com'
    name             'Joe Bloggs'
    provider         'developer'
    uid              '1234'
    password "password"
    password_confirmation "password"
    accepted_terms   true
    premium_subscription false
  end
end
