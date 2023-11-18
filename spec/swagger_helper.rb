# frozen_string_literal: true

require 'rails_helper'
require 'yaml'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('app/api_docs').to_s

  # Load the combined YAML file from app/api_docs
  api_docs_yaml = YAML.load_file(Rails.root.join('app/api_docs/api_documentation.yml'))

  config.swagger_docs = {
    'api_documentation.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: api_docs_yaml,
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ]
    }
  }

  config.swagger_format = :yaml
end
