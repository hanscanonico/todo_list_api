# frozen_string_literal: true

class List < ApplicationRecord
  has_many :tasks, dependent: :destroy

  belongs_to :user

  validates :name, presence: true
  validates :name, length: { minimum: 2, maximum: 30 }
  validates :order, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
end
