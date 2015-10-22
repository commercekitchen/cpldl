Rails.application.routes.draw do

  root 'home#index'

  get 'login/new', as: :login
  resource :account, only: [:show, :update]
  resource :profile, only: [:show, :update]
  resources :courses, only: [:index, :show] do
    resources :lessons, only: [:index, :show]
  end

  mount Ckeditor::Engine => '/ckeditor'

  namespace :admin do
    root 'dashboard#index'
    resources :dashboard, only: [:index]
    resources :courses
  end

  devise_for :users , controllers: { registrations: 'registrations' }

end
