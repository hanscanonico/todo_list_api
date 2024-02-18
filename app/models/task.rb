# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :list

  validates :name, length: { minimum: 3, maximum: 30 }
  validates :order, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
end
