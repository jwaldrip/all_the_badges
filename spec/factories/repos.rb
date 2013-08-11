# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repo do
    user
    name 'all_the_badges'
  end
end
