# frozen_string_literal: true

require 'rails_helper'

RSpec.describe List do
  let!(:user) { create(:user) }

  # Test suite for validating the presence of the list's name
  describe 'validations' do
    it 'is valid with valid attributes' do
      list = described_class.new(name: 'Groceries', user:, order: 1)
      expect(list).to be_valid
    end

    it 'is not valid without a name' do
      list = described_class.new(name: nil)
      expect(list).not_to be_valid
    end

    it 'is not valid with a name shorter than 2 characters' do
      list = described_class.new(name: 'a')
      expect(list).not_to be_valid
    end

    it 'is not valid with a name longer than 30 characters' do
      list = described_class.new(name: 'a' * 31)
      expect(list).not_to be_valid
    end

    it 'is not valid without an order' do
      list = described_class.new(order: nil)
      expect(list).not_to be_valid
    end

    it 'is not valid with an order less than 1' do
      list = described_class.new(order: 0)
      expect(list).not_to be_valid
    end

    it 'is not valid with an order that is not an integer' do
      list = described_class.new(order: 'not an integer')
      expect(list).not_to be_valid
    end
  end

  # Test suite for List model associations
  describe 'associations' do
    it 'has many tasks' do
      assc = described_class.reflect_on_association(:tasks)
      expect(assc.macro).to eq :has_many
    end
  end

  # Add more tests for methods or scopes you may have on your List model
end
