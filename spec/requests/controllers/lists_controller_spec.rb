# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ListsController, type: :controller do
  describe 'POST #create' do
    it 'creates a new List' do
      expect do
        post :create, params: { list: { name: 'New List' } }
      end.to change(List, :count).by(1)
    end
  end
end
