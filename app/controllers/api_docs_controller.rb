# frozen_string_literal: true

class ApiDocsController < ApplicationController
  def api_spec
    api_doc_path = Rails.root.join('/api_docs/api_documentation.yml')
    yaml_content = YAML.load_file(api_doc_path)
    yaml_string = YAML.dump(yaml_content)

    render plain: yaml_string, content_type: 'application/yaml'
  end
end
