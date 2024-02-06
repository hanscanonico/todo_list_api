# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: 'users/passwords'
  }, defaults: { format: :json }

  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :lists do
    member do
      patch :switch_order
    end
    resources :tasks do
      member do
        patch :toggle, :switch_order
      end
    end
  end

  get '/api-docs', to: 'api_docs#api_spec'

  root to: redirect('/api-docs/index.html')
end
