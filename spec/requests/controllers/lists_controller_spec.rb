# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ListsController, type: :request do
  include Committee::Rails::Test::Methods

  let!(:headers) { { 'Content-Type' => 'application/json' } }

  describe 'POST /lists' do
    it 'creates a new list' do
      expect do
        post lists_path, params: { name: 'New List' }.to_json,
                         headers:
      end.to change(List, :count).by(1)

      assert_request_schema_confirm
      assert_response_schema_confirm(201)

      expect(JSON.parse(response.body)['name']).to eq('New List')
    end
  end

  describe 'GET /lists' do
    let!(:list1) { List.create(name: 'List 1') }
    let!(:list2) { List.create(name: 'List 2') }

    it 'retrieves all lists' do
      get lists_path

      assert_request_schema_confirm
      assert_response_schema_confirm(200)

      expect(JSON.parse(response.body).size).to eq(2)
      expect(JSON.parse(response.body).map { |l| l['name'] }).to match_array(['List 1', 'List 2'])
    end
  end

  describe 'DELETE /lists/{id}' do
    let!(:list) { List.create(name: 'List to delete') }

    it 'deletes a list' do
      expect do
        delete list_path(list)
      end.to change(List, :count).by(-1)

      assert_request_schema_confirm
      assert_response_schema_confirm(200)
    end

    context 'when the list has tasks' do
      let!(:task) { Task.create(name: 'Task 1', list:) }

      it 'deletes the list and its tasks' do
        expect do
          delete list_path(list)
        end.to change(List, :count).by(-1).and change(Task, :count).by(-1)

        assert_request_schema_confirm
        assert_response_schema_confirm(200)
      end
    end

    context 'when the list does not exist' do
      let!(:list) { { id: 9999 } }

      it 'returns a not found error' do
        delete list_path(list)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('List not found')
      end
    end
  end

  describe 'PUT /lists/{id}' do
    let!(:list) { List.create(name: 'List to update') }

    it 'updates a list' do
      put(list_path(list), params: { name: 'Updated List' }.to_json, headers:)

      expect(response).to have_http_status(:ok)
      expect(list.reload.name).to eq('Updated List')
    end

    context 'when the list does not exist' do
      let!(:list) { { id: 9999 } }

      it 'returns a not found error' do
        put(list_path(list), params: { name: 'Updated List' }.to_json, headers:)

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('List not found')
      end
    end
  end
end
