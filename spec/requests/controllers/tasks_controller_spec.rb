# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe TasksController, type: :request do
  include Committee::Rails::Test::Methods

  let!(:list1) { create(:list, name: 'list 1') }
  let!(:task1) { create(:task, name: 'task 1', list: list1, done: false) }
  let!(:task2) { create(:task, name: 'task 2', list: list1) }

  let!(:headers) { { 'Content-Type' => 'application/json' } }

  describe 'POST /lists/:list_id/tasks' do
    it 'creates a new task' do
      expect do
        post list_tasks_path(list1), params: { name: 'Task 3' }.to_json,
                                     headers:
      end.to change(Task, :count).by(1)

      assert_request_schema_confirm
      assert_response_schema_confirm(201)

      expect(JSON.parse(response.body)['name']).to eq('Task 3')
    end
  end

  describe 'GET /lists/:list_id/tasks' do
    it 'shows all tasks for a specific list' do
      get list_tasks_path(list1)

      assert_request_schema_confirm
      assert_response_schema_confirm(200)

      expect(response.parsed_body.size).to eq(2)
      expect(response.parsed_body).to include(include('name' => 'task 1'), include('name' => 'task 2'))
    end
  end

  describe 'DELETE /lists/:list_id/tasks/{id}' do
    it 'deletes a task' do
      expect do
        delete list_task_path(list1, task1)
      end.to change(Task, :count).by(-1)

      assert_request_schema_confirm
      assert_response_schema_confirm(200)
    end

    context 'when the list does not exist' do
      let!(:not_existing_list_id) { 9999 }
      it 'returns a not found error' do
        delete list_task_path(not_existing_list_id, task1)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('List not found')
      end
    end

    context 'when the task does not exist' do
      let!(:not_existing_task_id) { 9999 }
      it 'returns a not found error' do
        delete list_task_path(list1, not_existing_task_id)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Task not found')
      end
    end
  end

  describe 'PATCH /lists/:list_id/tasks/{id}' do
    it 'updates the task' do
      expect(task1.name).to eq('task 1')

      patch(list_task_path(list1, task1), params: { task: { name: 'Updated Task' } }.to_json, headers:)

      assert_request_schema_confirm
      assert_response_schema_confirm(200)

      expect(task1.reload.name).to eq('Updated Task')
    end

    context 'when the list does not exist' do
      let!(:not_existing_list_id) { 9999 }

      it 'returns a not found error' do
        patch(list_task_path(not_existing_list_id, task1), params: { task: { name: 'Updated Task' } }.to_json, headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('List not found')
      end
    end

    context 'when the task does not exist' do
      let!(:not_existing_task_id) { 9999 }

      it 'returns a not found error' do
        patch(list_task_path(list1, not_existing_task_id), params: { task: { name: 'Updated Task' } }.to_json, headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Task not found')
      end
    end
  end

  describe 'PATCH /lists/:list_id/tasks/{id}/toggle' do
    context 'when the task is not done' do
      it 'does the task' do
        expect(task1.done).to eq(false)
        patch toggle_list_task_path(list1, task1)

        assert_request_schema_confirm
        assert_response_schema_confirm(200)

        expect(task1.reload.done).to eq(true)
      end
    end
    context 'when the task is done' do
      let!(:task1) { create(:task, name: 'task 1', list: list1, done: true) }
      it 'undoes the task' do
        expect(task1.done).to eq(true)
        patch toggle_list_task_path(list1, task1)

        assert_request_schema_confirm
        assert_response_schema_confirm(200)

        expect(task1.reload.done).to eq(false)
      end
    end

    context 'when the list does not exist' do
      let!(:not_existing_list_id) { 9999 }

      it 'returns a not found error' do
        patch toggle_list_task_path(not_existing_list_id, task1)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('List not found')
      end
    end

    context 'when the task does not exist' do
      let!(:not_existing_task_id) { 9999 }

      it 'returns a not found error' do
        patch toggle_list_task_path(list1, not_existing_task_id)

        assert_request_schema_confirm
        assert_response_schema_confirm(404)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Task not found')
      end
    end
  end
end
