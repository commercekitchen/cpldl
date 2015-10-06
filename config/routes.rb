Rails.application.routes.draw do

  devise_for :users
  root 'home#index'

  resource :profile, only: [:show, :update]

end
