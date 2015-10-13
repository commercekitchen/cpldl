Rails.application.routes.draw do

  root 'home#index'

  devise_for :users
  get 'user_accounts/new', as: :user_account

  resource :profile, only: [:show, :update]

  resources :courses, only: [:show, :index]
  resources :topics
  resources :languages


  resources :administrators, only: [:index]

  namespace :administrators do 
    resources :courses
    resources :attachments
    resources :topics
    resources :languages
  end
end
