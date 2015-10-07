Rails.application.routes.draw do

  root 'home#index'
  
  devise_for :users
    get 'user_accounts/new'
  
  resource :profile, only: [:show, :update]

end
