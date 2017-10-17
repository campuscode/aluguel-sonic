Rails.application.routes.draw do

  root to: 'home#index'

  get "/search" => "home#search"
  resources :properties, only: [:show, :new, :create] do
    resources :proposals, shallow: true
  end
end
