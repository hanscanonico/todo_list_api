# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ListsController, type: :controller do
  let!(:list1) { create(:list, name: 'list 1') }
  let!(:list2) { create(:list, name: 'list 2') }

  describe '#create' do
    it 'creates a new List' do
      expect do
        post :create, params: { list: { name: 'New List' } }
      end.to change(List, :count).by(1)
      expect(response.parsed_body['name']).to eq('New List')
      expect(response).to have_http_status(:success)
    end
  end

  describe '#index' do
    it 'shows all the lists' do
      get :index, params: { list_id: list1.id }
      expect(response).to have_http_status(:success)
      expect(response.parsed_body.size).to eq(2)
      expect(response.parsed_body).to include(include('name' => 'list 1'), include('name' => 'list 2'))
    end
  end

  describe '#delete' do
    it 'deletes a list' do
      expect(List.count).to eq(2)
      post :destroy, params: { id: list1.id }
      expect(response).to have_http_status(:success)
      expect(List.count).to eq(1)
    end
  end

  describe '#put' do
    it 'updates the list' do
      expect(list1.name).to eq('list 1')
      put :update, params: { id: list1.id, list: { name: 'Updated List' } }
      expect(response).to have_http_status(:success)
      expect(list1.reload.name).to eq('Updated List')
    end
  end
end
