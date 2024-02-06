# frozen_string_literal: true

require 'swagger_helper'
require 'devise/jwt/test_helpers'

RSpec.describe TasksController, type: :request do
  include Committee::Rails::Test::Methods

  let!(:list1) { create(:list, name: 'list 1', user:) }
  let!(:list2) { create(:list, name: 'list 2', user: other_user) }
  let!(:task1) { create(:task, name: 'task 1', list: list1, done: false) }
  let!(:task2) { create(:task, name: 'task 2', list: list1) }
  let!(:task3) { create(:task, name: 'task 3', list: list2) }

  let!(:headers) { { 'Content-Type' => 'application/json' } }
  let!(:user) { create(:user).tap(&:confirm) }
  let!(:other_user) { create(:user).tap(&:confirm) }
  let!(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'POST /lists/:list_id/tasks' do
    it 'creates a new task' do
      expect do
        post list_tasks_path(list1), params: { name: 'Task 3' }.to_json,
                                     headers: auth_headers
      end.to change(Task, :count).by(1)

      assert_request_schema_confirm
      assert_response_schema_confirm(201)

      expect(json['name']).to eq('Task 3')
    end

    context 'when tasks already exist' do
      let!(:list3) { create(:list, name: 'list 3', user:) }
      let!(:task1_3) { create(:task, name: 'Task 1', list: list3, order: 1) }
      let!(:task2_3) { create(:task, name: 'Task 2', list: list3, order: 2) }

      it 'creates a new task with the correct order' do
        post list_tasks_path(list3), params: { name: 'Task 3' }.to_json,
                                     headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(201)
        expect(Task.last.order).to eq(3)
      end
    end

    context 'when the auth token is not send' do
      it 'raises an unauthorized error' do
        post(list_tasks_path(list1), params: { name: 'Task 3' }.to_json,
                                     headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(401)
      end
    end

    context 'when the list does not exist' do
      let!(:not_existing_list_id) { 9999 }

      it 'returns a not found error' do
        post list_tasks_path(not_existing_list_id), params: { name: 'Task 3' }.to_json,
                                                    headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end
  end

  describe 'GET /lists/:list_id/tasks' do
    it 'shows all tasks for a specific list, for the current user' do
      get list_tasks_path(list1), headers: auth_headers

      assert_request_schema_confirm
      assert_response_schema_confirm(200)

      expect(response.parsed_body.size).to eq(2)
      expect(response.parsed_body).to include(include('name' => 'task 1'), include('name' => 'task 2'))
    end
  end

  describe 'DELETE /lists/:list_id/tasks/{id}' do
    it 'deletes a task' do
      expect do
        delete list_task_path(list1, task1), headers: auth_headers
      end.to change(Task, :count).by(-1)

      assert_request_schema_confirm
      assert_response_schema_confirm(200)
    end

    context 'when the auth token is not send' do
      it 'raises an unauthorized error' do
        delete list_task_path(list1, task1)

        assert_request_schema_confirm
        assert_response_schema_confirm(401)
      end
    end

    context 'when the list does not exist' do
      let!(:not_existing_list_id) { 9999 }
      it 'returns a not found error' do
        delete list_task_path(not_existing_list_id, task1), headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end

    context 'when the task does not exist' do
      let!(:not_existing_task_id) { 9999 }
      it 'returns a not found error' do
        delete list_task_path(list1, not_existing_task_id), headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('Task not found')
      end
    end

    context 'when the task belongs to a list of another user' do
      it 'returns a not found error' do
        delete list_task_path(list2, task3), headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end
  end

  describe 'PATCH /lists/:list_id/tasks/{id}' do
    it 'updates the task' do
      expect(task1.name).to eq('task 1')

      patch(list_task_path(list1, task1), params: { task: { name: 'Updated Task' } }.to_json, headers: auth_headers)

      assert_request_schema_confirm
      assert_response_schema_confirm(200)

      expect(task1.reload.name).to eq('Updated Task')
    end

    context 'when the auth token is not send' do
      it 'raises an unauthorized error' do
        patch(list_task_path(list1, task1), params: { task: { name: 'Updated Task' } }.to_json, headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(401)
      end
    end

    context 'when the list does not exist' do
      let!(:not_existing_list_id) { 9999 }

      it 'returns a not found error' do
        patch(list_task_path(not_existing_list_id, task1), params: { task: { name: 'Updated Task' } }.to_json,
                                                           headers: auth_headers)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end

    context 'when the task does not exist' do
      let!(:not_existing_task_id) { 9999 }

      it 'returns a not found error' do
        patch(list_task_path(list1, not_existing_task_id), params: { task: { name: 'Updated Task' } }.to_json,
                                                           headers: auth_headers)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('Task not found')
      end
    end

    context 'when the task belongs to a list of another user' do
      it 'returns a not found error' do
        patch(list_task_path(list2, task3), params: { task: { name: 'Updated Task' } }.to_json, headers: auth_headers)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end
  end

  describe 'PATCH /lists/:list_id/tasks/{id}/toggle' do
    context 'when the task is not done' do
      it 'does the task' do
        expect(task1.done).to eq(false)
        patch toggle_list_task_path(list1, task1), headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(200)

        expect(task1.reload.done).to eq(true)
      end
    end

    context 'when the auth token is not send' do
      it 'raises an unauthorized error' do
        patch toggle_list_task_path(list1, task1)

        assert_request_schema_confirm
        assert_response_schema_confirm(401)
      end
    end

    context 'when the task is done' do
      let!(:task1) { create(:task, name: 'task 1', list: list1, done: true) }
      it 'undoes the task' do
        expect(task1.done).to eq(true)
        patch toggle_list_task_path(list1, task1), headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(200)

        expect(task1.reload.done).to eq(false)
      end
    end

    context 'when the list does not exist' do
      let!(:not_existing_list_id) { 9999 }

      it 'returns a not found error' do
        patch toggle_list_task_path(not_existing_list_id, task1), headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end

    context 'when the task does not exist' do
      let!(:not_existing_task_id) { 9999 }

      it 'returns a not found error' do
        patch toggle_list_task_path(list1, not_existing_task_id), headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('Task not found')
      end
    end

    context 'when the task belongs to a list of another user' do
      it 'returns a not found error' do
        patch toggle_list_task_path(list2, task3), headers: auth_headers

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end
  end

  describe 'PATCH /lists/:list_id/tasks/{id}/switch_order' do
    it 'switches the order of two tasks' do
      order_task1 = task1.order
      order_task2 = task2.order

      patch(switch_order_list_task_path(list1, task1), params: { task_id: task2.id }.to_json, headers: auth_headers)

      assert_request_schema_confirm
      assert_response_schema_confirm(200)

      expect(task1.reload.order).to eq(order_task2)
      expect(task2.reload.order).to eq(order_task1)
    end

    context 'when the auth token is not send' do
      it 'raises an unauthorized error' do
        patch(switch_order_list_task_path(list1, task1), params: { task_id: task2.id }.to_json, headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(401)
      end
    end

    context 'when the list does not exist' do
      let!(:not_existing_list_id) { 9999 }

      it 'returns a not found error' do
        patch(switch_order_list_task_path(not_existing_list_id, task1), params: { task_id: task2.id }.to_json,
                                                                        headers: auth_headers)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end

    context 'when the task does not exist' do
      let!(:not_existing_task_id) { 9999 }

      it 'returns a not found error' do
        patch(switch_order_list_task_path(list1, not_existing_task_id), params: { task_id: task2.id }.to_json,
                                                                        headers: auth_headers)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('Task not found')
      end
    end

    context 'when the task belongs to a list of another user' do
      it 'returns a not found error' do
        patch(switch_order_list_task_path(list2, task3), params: { task_id: task2.id }.to_json, headers: auth_headers)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        expect(json['error']).to eq('List not found')
      end
    end
  end
end
