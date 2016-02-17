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
  get 'home_language_toggle', to: 'home#language_toggle'
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
    put 'lessons/sort', to: 'lessons#sort'
    resources :dashboard, only: [:index]
      get 'dashboard/invites_index', to: 'dashboard#invites_index', as: :invites_index
      get 'dashboard/pages_index', to: 'dashboard#pages_index', as: :pages_index
      get 'dashboard/users_index', to: 'dashboard#users_index', as: :users_index
      get 'dashboard/import_courses', to: 'dashboard#import_courses', as: :import_courses
      post 'dashboard/add_imported_course', to: 'dashboard#add_imported_course'
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

  devise_for :users, controllers: { registrations: 'registrations', invitations: 'admin/invites' }
  get 'users/invitation/accept', to: 'devise/invitations#edit'
  # accept_user_invitation GET    /users/invitation/accept(.:format) devise/invitations#edit

  match '/404', to: 'errors#error404', via: [:get, :post, :patch, :delete]
  match '/500', to: 'errors#error500', via: [:get, :post, :patch, :delete]
end
