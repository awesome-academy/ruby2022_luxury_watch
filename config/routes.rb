Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "homes#index"

    get "/signup", to: "users#new"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    get "/contact", to: "homes#contact"
    get "/cart", to: "carts#index"
    post "/add_to_cart/:id", to: "carts#create", as: "add_to_cart"
    post "/select_option_cart", to: "carts#select_cart"
    get "/remove_from_cart/:id", to: "carts#destroy"

    resources :users
    resources :account_activations, only: :edit
    resources :password_resets, except: %i(index destroy)
    resources :products
    resources :homes, only: :index

    namespace :admin do
      root "users#index"
      resources :users, only: %i(index update show)
    end
  end
end
