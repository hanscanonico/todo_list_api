# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task do
  describe 'validations' do
    it 'is valid with valid attributes' do
      list = List.new(name: 'Groceries')
      task = described_class.new(name: 'Buy milk', list:)
      expect(task).to be_valid
    end

    it 'is not valid without a name' do
      task = described_class.new(name: nil)
      expect(task).not_to be_valid
    end

    it 'is not valid with a name shorter than 3 characters' do
      task = described_class.new(name: 'a' * 2)
      expect(task).not_to be_valid
    end

    it 'is not valid with a name longer than 30 characters' do
      task = described_class.new(name: 'a' * 31)
      expect(task).not_to be_valid
    end
  end
end
