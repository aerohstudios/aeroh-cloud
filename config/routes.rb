Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  use_doorkeeper
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: "home#index"

  namespace :api do
    namespace :v1 do
      jsonapi_resources :devices
      jsonapi_resources :users, only: [:index, :show]
    end
  end

  resources :dashboard, only: [:index]
end
