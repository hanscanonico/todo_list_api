# frozen_string_literal: true

class List < ApplicationRecord
  has_many :tasks, dependent: :destroy

  belongs_to :user

  validates :name, presence: true
  validates :name, length: { minimum: 2, maximum: 30 }
end
