FactoryGirl.define do
  factory :user do
    # TODO: Migrant
    email            'developers@example.com'
    name             'Joe Bloggs'
    provider         'developer'
    uid              '1234'
    accepted_terms   true
  end
end
