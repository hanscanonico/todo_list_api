# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task do
  describe 'validations' do
    it 'is valid with valid attributes' do
      list = List.new(name: 'Groceries')
      task = described_class.new(name: 'Buy milk', list:, order: 1)
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

    it 'is not valid without an order' do
      task = described_class.new(order: nil)
      expect(task).not_to be_valid
    end

    it 'is not valid with an order less than 1' do
      task = described_class.new(order: 0)
      expect(task).not_to be_valid
    end

    it 'is not valid with an order that is not an integer' do
      task = described_class.new(order: 'not an integer')
      expect(task).not_to be_valid
    end
  end
end
