Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }
  devise_scope :user do
    get "users/edit_password", to: 'users/registrations#edit_password', as: 'edit_password'
    put 'users/edit_password', to: 'users/registrations#update_password', as: 'update_password'
  end
  root 'static_pages#home'
  get  '/contact', to: 'static_pages#contact'
  get  '/tos', to: 'static_pages#terms', as: 'terms'
  resources :users, only: [:show, :index] do
    member do
      get :following, :followers
      post :favorites
      post :my_works
      get :stocks
    end
  end
  resources :works do
    resources :likes, only: [:create, :destroy]
    collection do
      get 'get_category_children', defaults: { fomat: 'json' }
      get 'search', to: 'works#search'
    end
  end
  resources :comments, only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]
  resources :notifications, only: :index
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
