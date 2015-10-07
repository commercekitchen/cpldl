Rails.application.routes.draw do

  devise_for :users
  root 'home#index'

  get 'user_accounts/new'
end
