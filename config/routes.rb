Rails.application.routes.draw do

  root 'home#index'

  get 'login/new', as: :login
  resource :account, only: [:show, :update]
  resource :profile, only: [:show, :update]

  get 'courses/your' =>'courses#your', as: :your_courses
  get 'courses/completed' =>'courses#completed', as: :completed_courses
  resources :courses, only: [:index, :show] do
    post 'start'
    resources :lessons, only: [:index, :show] do
      post 'complete'
    end
  end

  namespace :admin do
    root 'dashboard#index'
    resources :dashboard, only: [:index]
    resources :courses do
      resources :lessons do
        collection do
          delete :destroy_asl_attachment
        end
      end
    end
  end

  devise_for :users , controllers: { registrations: 'registrations' }

end
