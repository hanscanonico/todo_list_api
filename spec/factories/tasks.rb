# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    name { 'Default Task Name' }
    sequence(:order)
  end
end
