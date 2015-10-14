Rails.application.routes.draw do

  root 'home#index'

  devise_for :users
  get 'user_accounts/new', as: :user_account

  resource :profile, only: [:show, :update]
  resources :courses, only: [:index, :show] do
    resources :lessons, only: [:index, :show]
  end

  mount Ckeditor::Engine => '/ckeditor'

  namespace :administrators do
    resources :dashboard
    resources :courses
    resources :attachments
    resources :topics
    resources :languages
  end
end
