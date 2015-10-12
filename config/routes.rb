Rails.application.routes.draw do

  root 'home#index'

  devise_for :users
  get 'user_accounts/new', as: :user_account

  resource :profile, only: [:show, :update]
  
  resources :courses
  resources :topics
  resources :languages
  resources :attachments
end
