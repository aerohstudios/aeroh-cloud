Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  use_doorkeeper
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: "home#index"

  namespace :api do
    namespace :v1 do
      jsonapi_resources :devices, only: [:index, :show, :update, :create, :destroy]
      post 'devices/:id/publish', to: 'devices#publish', constraints: { id: /\d*/ }

      jsonapi_resources :users, only: [:index, :show, :destroy]

      resources :authorizer, only: [:index]
    end
  end

  resources :dashboard, only: [:index]
end
