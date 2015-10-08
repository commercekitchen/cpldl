Rails.application.routes.draw do
  root 'home#index'
  
  devise_for :users
    get 'user_accounts/new', as: :user_account
  
  resource :profile, only: [:show, :update]
end
