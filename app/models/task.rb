# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :list

  validates_length_of :name, minimum: 3, maximum: 30
end
