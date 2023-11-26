# frozen_string_literal: true

class List < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates_presence_of :name
  validates_length_of :name, minimum: 2, maximum: 30
end
