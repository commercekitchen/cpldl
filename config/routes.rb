Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  root 'home#index'

  get 'login/new', as: :login
  resource :account, only: [:show, :update]
  resource :profile, only: [:show, :update]

  get 'courses/your' =>'courses#your', as: :your_courses
  get 'courses/completed' =>'courses#completed', as: :completed_courses
  resources :courses, only: [:index, :show] do
    post 'start'
    post 'add'
    post 'remove'
    resources :lessons, only: [:index, :show] do
      post 'complete'
    end
  end

  namespace :admin do
    root 'dashboard#index'
    resources :dashboard, only: [:index]
      get 'dashboard/pages_index', to: 'dashboard#pages_index', as: :pages_index
    resources :cms_pages do
      put :sort, on: :collection
    end
    resources :courses do
      put :sort, on: :collection
      resources :lessons do
        collection do
          delete :destroy_asl_attachment
        end
      end
    end
  end

  devise_for :users , controllers: { registrations: 'registrations' }

end
