# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Lists API 2', type: :request do
  path '/lists' do
    post 'Creates a new list' do
      tags 'Lists'
      consumes 'application/json'
      parameter name: :list, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: ['name']
      }

      response '201', 'list created' do
        let(:list) { { name: 'New List' } }
        run_test!
      end
    end

    get 'Retrieves all lists' do
      tags 'Lists'
      produces 'application/json'

      response '200', 'lists found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string }
                 },
                 required: %w[id name]
               }

        run_test!
      end
    end
  end

  path '/lists/{id}' do
    delete 'Deletes a list' do
      tags 'Lists'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'list deleted' do
        let(:id) { List.create(name: 'List to delete').id }
        run_test!
      end
    end

    put 'Updates a list' do
      tags 'Lists'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :integer
      parameter name: :list, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: ['name']
      }

      response '200', 'list updated' do
        let(:id) { List.create(name: 'List to update').id }
        let(:list) { { name: 'Updated List' } }
        run_test!
      end
    end
  end
end
