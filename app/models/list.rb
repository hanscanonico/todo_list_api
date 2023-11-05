# frozen_string_literal: true

class List < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates_presence_of :name
end
