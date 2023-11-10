# frozen_string_literal: true

Rails.application.routes.draw do
  resources :lists do
    resources :tasks
  end
end
