Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  root 'home#index'

  get 'login/new', as: :login
  resource :account, only: [:show, :update]
  resource :profile, only: [:show, :update]

  get 'courses/your', to: 'courses#your', as: :your_courses
  get 'courses/completed', to: 'courses#completed', as: :completed_courses
  get 'courses/quiz', to: 'courses#quiz'
  post 'courses/quiz', to: 'courses#quiz_submit'
  resources :courses, only: [:index, :show] do
    post 'start'
    post 'add'
    post 'remove'
    get 'complete'
    get 'attachment/:attachment_id' => 'courses#view_attachment', as: :attachment
    resources :lessons, only: [:index, :show] do
      post 'complete'
    end
  end

  resources 'cms_pages', only: [:show]

  namespace :admin do
    root 'dashboard#index'
    resources :dashboard, only: [:index]
      get 'dashboard/pages_index', to: 'dashboard#pages_index', as: :pages_index
      get 'dashboard/users_index', to: 'dashboard#users_index', as: :users_index
      put 'dashboard/manually_confirm_user', to: 'dashboard#manually_confirm_user'
    resources :cms_pages do
      put :sort, on: :collection
      patch 'update_pub_status'
    end
    resources :courses do
      put :sort, on: :collection
      patch 'update_pub_status'
      resources :lessons do
        collection do
          delete :destroy_asl_attachment
        end
      end
    end

    resources :attachments, only: [:destroy]
  end

  devise_for :users , controllers: { registrations: 'registrations' }

end
