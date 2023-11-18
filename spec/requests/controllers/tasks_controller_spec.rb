# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe TasksController, type: :controller do
  let!(:list1) { create(:list, name: 'list 1') }
  let!(:task1) { create(:task, name: 'task 1', list: list1, done: false) }
  let!(:task2) { create(:task, name: 'task 2', list: list1) }

  describe '#create' do
    it 'creates a new task' do
      expect do
        post :create, params: { list_id: list1.id, task: { name: 'Task 3' } }
      end.to change(Task, :count).by(1)
      expect(response.parsed_body['name']).to eq('Task 3')
      expect(response).to have_http_status(:success)
    end
  end

  describe '#index' do
    it 'shows all tasks for a specific list' do
      get :index, params: { list_id: list1.id }
      expect(response).to have_http_status(:success)
      expect(response.parsed_body.size).to eq(2)
      expect(response.parsed_body).to include(include('name' => 'task 1'), include('name' => 'task 2'))
    end
  end

  describe '#destroy' do
    it 'deletes a task' do
      expect do
        delete :destroy, params: { list_id: list1.id, id: task1.id }
      end.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:success)
    end
  end

  describe '#put' do
    it 'updates the list' do
      expect(task1.name).to eq('task 1')
      put :update, params: { id: task1.id, list_id: list1.id, task: { name: 'Updated Task' } }
      expect(response).to have_http_status(:success)
      expect(task1.reload.name).to eq('Updated Task')
    end
  end

  describe '#toggle' do
    context 'when the task is not done' do
      it 'does the task' do
        expect(task1.done).to eq(false)
        patch :toggle, params: { id: task1.id, list_id: list1.id }
        expect(response).to have_http_status(:success)
        expect(task1.reload.done).to eq(true)
      end
    end
    context 'when the task is done' do
      let!(:task1) { create(:task, name: 'task 1', list: list1, done: true) }
      it 'undoes the task' do
        expect(task1.done).to eq(true)
        patch :toggle, params: { id: task1.id, list_id: list1.id }
        expect(response).to have_http_status(:success)
        expect(task1.reload.done).to eq(false)
      end
    end
  end
end
