# frozen_string_literal: true

require 'rails_helper'
require 'yaml'

RSpec.configure do |config|
  config.openapi_root = Rails.public_path.join('api_docs').to_s

  # Load the combined YAML file from app/api_docs
  api_docs_yaml = YAML.load_file(Rails.public_path.join('api_docs/api_documentation.yml'))

  config.openapi_specs = {
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

  config.openapi_format = :yaml
end
