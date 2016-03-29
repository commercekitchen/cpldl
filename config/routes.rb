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
    get 'skills', to: 'courses#skills', as: :skills
    resources :lessons, only: [:index, :show] do
      get 'lesson_complete'
      post 'complete'
    end
  end

  resources 'cms_pages', only: [:show]

  namespace :trainer do
    root 'home#index'
    resources :dashboard, only: [:index]
      put 'dashboard/manually_confirm_user', to: 'dashboard#manually_confirm_user'
  end

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

      patch 'users/:id/change_user_roles', to: 'users#change_user_roles', as: :change_user_roles

    resources :courses do
      put :sort, on: :collection
      patch 'update_pub_status'

      resources :lessons do
        collection do
          delete :destroy_asl_attachment
        end
      end
    end

    get 'export_completions', to: 'exports#completions', as: :export_completions

    resources :attachments, only: [:destroy]
  end

  devise_for :users, controllers: { registrations: 'registrations', invitations: 'admin/invites' }
  get 'users/invitation/accept', to: 'devise/invitations#edit'
  # accept_user_invitation GET    /users/invitation/accept(.:format) devise/invitations#edit

  match '/404', to: 'errors#error404', via: [:get, :post, :patch, :delete]
  match '/500', to: 'errors#error500', via: [:get, :post, :patch, :delete]

  # These are all the redirects needed to keep things working from the old site.
  # They are coming from links on external sites that we can't update or change.
  # Please don't delete them.
  # ~~~ Start of redirect matchers ~~~ #
  get '/learn', to: redirect('/courses')
  get '/teach', to: redirect('http://community.digitallearn.org')
  get '/teach/*path', to: redirect('http://community.digitallearn.org')
  get '/about', to: redirect('/cms_pages/about-digitallearn-org')
  get '/get-help', to: redirect('/cms_pages/about-digitallearn-org')
  get '/learn/getting-started-computer', to: redirect('/courses/getting-started-on-a-computer')
  get '/learn/getting-started-computer/keyboard', to: redirect('/courses/getting-started-on-a-computer/lessons/the-keyboard')
  get '/learn/getting-started-computer/mouse', to: redirect('/courses/getting-started-on-a-computer/lessons/the-mouse')
  get '/learn/getting-started-computer/what-computer', to: redirect('/courses/getting-started-on-a-computer/lessons/what-is-a-computer')
  get '/learn/intro-email/compose-and-send', to: redirect('/courses/intro-to-email/lessons/compose-and-send')
  get '/learn/basic-search', to: redirect('/courses/basic-search')
  get '/learn/basic-search/ads-search-results', to: redirect('/courses/basic-search/lessons/ads-in-search-results')
  get '/learn/basic-search/what-search-engine', to: redirect('/courses/basic-search/lessons/what-is-a-search-engine')
  get '/learn/buying-plane-ticket', to: redirect('/courses/buying-a-plane-ticket')
  get '/learn/cloud-storage', to: redirect('/courses/cloud-storage')
  get '/learn/cloud-storage/googledrive-and-skydrive', to: redirect('/courses/cloud-storage/lessons/google-drive-and-skydrive')
  get '/learn/cloud-storage/introduction-dropbox', to: redirect('/courses/cloud-storage/lessons/dropbox')
  get '/learn/cloud-storage/sharing-cloud', to: redirect('/courses/cloud-storage/lessons/sharing')
  get '/learn/cloud-storage/what-cloud-storage', to: redirect('/courses/cloud-storage/lessons/what-is-cloud-storage')
  get '/learn/creating-resumes/what-resume', to: redirect('/courses/creating-resumes/lessons/what-is-a-resume')
  get '/learn/intro-email', to: redirect('/courses/intro-to-email')
  get '/learn/intro-email/log', to: redirect('/courses/intro-to-email/lessons/logging-in')
  get '/learn/intro-email/open-messages-and-reply', to: redirect('/courses/intro-to-email/lessons/messages-and-replies')
  get '/learn/intro-email/quiz', to: redirect('/courses/intro-to-email/lessons/quiz')
  get '/learn/intro-email/sign-email', to: redirect('/courses/intro-to-email/lessons/sign-up-for-email')
  get '/learn/intro-email/what-email', to: redirect('/courses/intro-to-email/lessons/what-is-email')
  get '/learn/intro-facebook', to: redirect('/courses/intro-to-facebook')
  get '/learn/intro-facebook/finding-friends-facebook', to: redirect('/courses/intro-to-facebook/lessons/friends')
  get '/learn/intro-facebook/privacy-settings-facebook', to: redirect('/courses/intro-to-facebook/lessons/privacy')
  get '/learn/intro-facebook/setting-facebook-profile', to: redirect('/courses/intro-to-facebook/lessons/profiles')
  get '/learn/intro-facebook/status-updates-and-comments', to: redirect('courses/intro-to-facebook/lessons/posts-and-comments')
  get '/learn/intro-facebook/what-social-media', to: redirect('/courses/intro-to-facebook/lessons/why-facebook')
  get '/learn/intro-microsoft-word/learn/intro-microsoft-word', to: redirect('/courses/microsoft-word')
  get '/learn/intro-microsoft-word/cut-copy-paste', to: redirect('/learn/intro-microsoft-word/cut-copy-paste')
  get '/learn/intro-microsoft-word/intro-word', to: redirect('/courses/microsoft-word/lessons/introduction-cb8925aa-693e-4a82-82e4-f0c339fccad4')
  get '/learn/navigating-website', to: redirect('/courses/navigating-a-website')
  get '/learn/navigating-website/finding-website', to: redirect('/courses/navigating-a-website/lessons/finding-a-site')
  get '/learn/navigating-website/introduction', to: redirect('/courses/navigating-a-website/lessons/introduction-87a299c6-d872-490c-9673-bdd44a05f416')
  get '/learn/navigating-website/parts-website', to: redirect('/courses/navigating-a-website/lessons/parts-of-a-site')
  get '/learn/online-job-searching', to: redirect('/courses/online-job-searching')
  get '/learn/using-mac-os-x-0', to: redirect('/courses/using-a-mac-os-x')
  get '/learn/using-mac-os-x/deleting', to: redirect('/courses/using-a-mac-os-x/lessons/deleting')
  get '/learn/using-mac-os-x/desktop', to: redirect('/courses/using-a-mac-os-x/lessons/desktop')
  get '/learn/using-mac-os-x/files-and-folders', to: redirect('/courses/using-a-mac-os-x/lessons/files-and-folders')
  get '/learn/using-mac-os-x/saving-and-closing', to: redirect('/courses/using-a-mac-os-x/lessons/saving-and-closing')
  get '/learn/using-mac-os-x/using-window', to: redirect('/courses/using-a-mac-os-x/lessons/using-windows')
  get '/learn/using-mac-os-x/what-operating-system', to: redirect('/courses/using-a-mac-os-x/lessons/operating-systems')
  get '/learn/using-pc-windows-7', to: redirect('/courses/using-a-pc-windows-7')
  get '/learn/using-pc-windows-7/deleting', to: redirect('/courses/using-a-pc-windows-7/lessons/deleting-00c3d7bd-08a0-4fa9-8ed6-983ebafe8f9c')
  get '/learn/using-pc-windows-7/desktop', to: redirect('/courses/using-a-pc-windows-7/lessons/desktop-ee99c258-c10a-49f2-b046-915b339aed58')
  get '/learn/using-pc-windows-7/files-and-folders', to: redirect('/courses/using-a-pc-windows-7/lessons/files-and-folders-ba05484a-96d9-456c-b872-f150bd2f3ed5')
  get '/learn/using-pc-windows-7/saving-and-closing', to: redirect('/courses/using-a-pc-windows-7/lessons/saving-and-closing-030d2785-b289-4612-a032-83251c911764')
  get '/learn/using-pc-windows-7/using-window', to: redirect('/courses/using-a-pc-windows-7/lessons/using-windows-8252b6fc-d896-464d-92bd-06f00f9cb2bd')
  get '/learn/using-pc-windows-7/what-windows', to: redirect('/courses/using-a-pc-windows-7/lessons/what-is-windows')
  get '/learn/getting-started-computer/ports', to: redirect('/courses/getting-started-on-a-computer/lessons/ports-9af76a46-c0b7-485a-9422-bcb32f624f8a')
  # ~~~ End of redirect matchers ~~~ #
end
