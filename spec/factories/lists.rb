# frozen_string_literal: true

FactoryBot.define do
  factory :list do
    name { 'Default List Name' }
    sequence(:order)
  end
end
