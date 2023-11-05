# frozen_string_literal: true

Rails.application.routes.draw do
  resources :lists do
    resources :tasks, only: %i[index create]
  end
  resources :tasks, only: %i[show update destroy]
end
