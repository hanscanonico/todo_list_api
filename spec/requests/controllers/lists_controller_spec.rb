# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe ListsController, type: :controller do
  describe '#create' do
    it 'creates a new list' do
      expect do
        post :create, params: { list: { name: 'New List' } }
      end.to change(List, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['name']).to eq('New List')
    end
  end

  describe '#index' do
    let!(:list1) { List.create(name: 'List 1') }
    let!(:list2) { List.create(name: 'List 2') }

    it 'retrieves all lists' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
      expect(JSON.parse(response.body).map { |l| l['name'] }).to match_array(['List 1', 'List 2'])
    end
  end

  describe '#destroy' do
    let!(:list) { List.create(name: 'List to delete') }

    it 'deletes a list' do
      expect do
        delete :destroy, params: { id: list.id }
      end.to change(List, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end

    context 'when the list has tasks' do
      let!(:task) { Task.create(name: 'Task 1', list:) }

      it 'deletes the list and its tasks' do
        expect do
          delete :destroy, params: { id: list.id }
        end.to change(List, :count).by(-1).and change(Task, :count).by(-1)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the list does not exist' do
      it 'returns a not found error' do
        delete :destroy, params: { id: 9999 }
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('List not found')
      end
    end
  end

  describe '#update' do
    let!(:list) { List.create(name: 'List to update') }

    it 'updates a list' do
      put :update, params: { id: list.id, list: { name: 'Updated List' } }
      expect(response).to have_http_status(:ok)
      expect(list.reload.name).to eq('Updated List')
    end

    context 'when the list does not exist' do
      it 'returns a not found error' do
        put :update, params: { id: 9999, list: { name: 'Updated List' } }
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('List not found')
      end
    end
  end
end
