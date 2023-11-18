# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :lists do
    resources :tasks do
      member do
        patch :toggle
      end
    end
  end

  get '/api-docs', to: 'api_docs#api_spec'
  root to: redirect('/api-docs/index.html')
end
