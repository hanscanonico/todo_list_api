# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe ListsController do
  include Committee::Rails::Test::Methods

  let!(:headers) { { 'Content-Type' => 'application/json' } }
  let!(:user) { create(:user).tap(&:confirm) }

  let!(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'POST /lists' do
    it 'creates a new list' do
      expect do
        post lists_path, params: { name: 'New List' }.to_json,
                         headers: auth_headers
      end.to change(List, :count).by(1)

      assert_request_schema_confirm
      assert_response_schema_confirm(201)

      expect(json['name']).to eq('New List')
    end

    context 'when lists already exist' do
      before do
        create(:list, name: 'List 1', user:, order: 1)
        create(:list, name: 'List 2', user:, order: 2)
      end

      it 'creates a new list with the correct order' do
        post lists_path, params: { name: 'New List' }.to_json,
                         headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(201)

        expect(List.last.order).to eq(3)
      end
    end

    context 'when the auth token is not send' do
      it 'raises an unauthorized error' do
        post(lists_path, params: { name: 'New List' }.to_json,
                         headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(401)
      end
    end
  end

  describe 'GET /lists' do
    let(:other_user) { create(:user).tap(&:confirm) }

    before do
      create(:list, name: 'List 1', user:)
      create(:list, name: 'List 2', user:)
      create(:list, name: 'Other User List', user: other_user)
    end

    it 'retrieves all lists of the user and only the user' do
      get lists_path, headers: auth_headers

      assert_request_schema_confirm
      assert_response_schema_confirm(200)

      expect(json.size).to eq(2)
      expect(json.pluck('name')).to contain_exactly('List 1', 'List 2')
    end

    context 'when the auth token is not send' do
      it 'raises an unauthorized error' do
        get(lists_path, headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(401)
      end
    end
  end

  describe 'DELETE /lists/{id}' do
    let!(:list) { create(:list, name: 'List to delete', user:) }

    it 'deletes a list' do
      expect do
        delete list_path(list), headers: auth_headers
      end.to change(List, :count).by(-1)

      assert_request_schema_confirm
      assert_response_schema_confirm(200)
    end

    context 'when the auth token is not send' do
      it 'raises an unauthorized error' do
        delete list_path(list)

        assert_request_schema_confirm
        assert_response_schema_confirm(401)
      end
    end

    context 'when the list has tasks' do
      before do
        create(:task, name: 'Task 1', list:)
      end

      it 'deletes the list and its tasks' do
        expect do
          delete list_path(list), headers: auth_headers
        end.to change(List, :count).by(-1).and change(Task, :count).by(-1)

        assert_request_schema_confirm
        assert_response_schema_confirm(200)
      end
    end

    context 'when the list does not exist' do
      let!(:list) { { id: 9999 } }

      it 'returns a not found error' do
        delete list_path(list), headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end

    context 'when the list does not belong to the user' do
      let!(:other_user) { create(:user).tap(&:confirm) }
      let!(:list) { create(:list, name: 'List to delete', user: other_user) }

      it 'returns a not found error' do
        delete list_path(list), headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end
  end

  describe 'PATCH /lists/{id}' do
    let!(:list) { create(:list, name: 'List to update', user:) }

    it 'updates a list' do
      patch(list_path(list), params: { name: 'Updated List' }.to_json, headers: auth_headers)

      expect(response).to have_http_status(:ok)
      expect(list.reload.name).to eq('Updated List')
    end

    context 'when the auth token is not send' do
      it 'raises an unauthorized error' do
        patch(list_path(list), params: { name: 'Updated List' }.to_json, headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(401)
      end
    end

    context 'when the list does not exist' do
      let!(:list) { { id: 9999 } }

      it 'returns a not found error' do
        put(list_path(list), params: { name: 'Updated List' }.to_json, headers: auth_headers)

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('List not found')
      end
    end

    context 'when the list does not belong to the user' do
      let!(:other_user) { create(:user).tap(&:confirm) }
      let!(:list) { create(:list, name: 'List to delete', user: other_user) }

      it 'returns a not found error' do
        put(list_path(list), params: { name: 'Updated List' }.to_json, headers: auth_headers)

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('List not found')
      end
    end
  end

  describe 'PATCH /lists/{id}/switch_order' do
    let!(:list1) { create(:list, name: 'List 1', user:) }
    let!(:list2) { create(:list, name: 'List 2', user:) }

    it 'switches the order of two lists' do
      order_list1 = list1.order
      order_list2 = list2.order

      patch(switch_order_list_path(list1), params: { id2: list2.id }.to_json, headers: auth_headers)

      assert_request_schema_confirm
      assert_response_schema_confirm(200)

      expect(list1.reload.order).to eq(order_list2)
      expect(list2.reload.order).to eq(order_list1)
    end

    context 'when the auth token is not send' do
      it 'raises an unauthorized error' do
        patch(switch_order_list_path(list1), params: { id2: list2.id }.to_json, headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(401)
      end
    end

    context 'when the list does not exist' do
      let!(:list1) { { id: 9999 } }
      let!(:list2) { { id: 9998 } }

      it 'returns a not found error' do
        patch(switch_order_list_path(list1), params: { id2: list2[:id] }.to_json, headers: auth_headers)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end

    context 'when the list does not belong to the user' do
      let!(:other_user) { create(:user).tap(&:confirm) }
      let!(:list1) { create(:list, name: 'List 1', user: other_user) }
      let!(:list2) { create(:list, name: 'List 2', user: other_user) }

      it 'returns a not found error' do
        patch(switch_order_list_path(list1), params: { id2: list2.id }.to_json, headers: auth_headers)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end
  end
end
