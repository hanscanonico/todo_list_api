# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :list

  validates :name, length: { minimum: 3, maximum: 30 }
end
