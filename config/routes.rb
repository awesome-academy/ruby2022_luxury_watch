require "sidekiq/web"
Rails.application.routes.draw do
  devise_for :users, only: :omniauth_callbacks, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  scope "(:locale)", locale: /en|vi/ do
    mount API::Base, at: "/"
    mount GrapeSwaggerRails::Engine, at: "/documentation"
    mount Sidekiq::Web => "/sidekiq"
    root "homes#index"
    get "/contact", to: "homes#contact"
    get "/cart", to: "carts#index"
    post "/add_to_cart/:id", to: "carts#create", as: "add_to_cart"
    post "/select_option_cart", to: "carts#select_cart"
    post "/update_cart", to: "carts#update"
    delete "/remove_from_cart/:id", to: "carts#destroy", as: "remove_from_cart"
    get "/check_code", to: "discounts#show", as: "check_code"
    as :user do
      get "/login", to: "devise/sessions#new"
      post "/login", to: "devise/sessions#create"
      delete "/logout", to: "devise/sessions#destroy"
      get "/signup", to: "devise/registrations#new"
    end
    devise_for :users, skip: :omniauth_callbacks
    resources :account_activations, only: :edit
    resources :password_resets, except: %i(index destroy)
    resources :products
    resources :homes, only: :index
    resources :comment_rates, only: %i(create destroy)
    resources :orders, except: %i(destroy edit)

    namespace :admin do
      root "users#index"
      resources :users, only: %i(index destroy show)
      resources :categories
      resources :products
      resources :orders
      resources :revenue_managements, only: %i(index)

      get "/list-user-delete", to: "users#list_users_delete"
      get "/search-users", to: "users#search", as: "search_users"
    end
  end
end
