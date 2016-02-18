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

  # These are all the redirects needed to keep things working from the old site.
  # They are coming from links on external sites that we can't update or change.
  # Please don't delete them.
  # ~~~ Start of redirect matchers ~~~ #
  match '/learn', to: redirect('/courses')
  match '/teach/*path', to: redirect('http://community.digitallearn.org')
  match '/about', to: redirect('/cms_pages/about-digitallearn-org')
  match '/get-help', to: redirect('/cms_pages/about-digitallearn-org')
  match '/learn/getting-started-computer', to: redirect('/courses/getting-started-on-a-computer')
  match '/learn/getting-started-computer/keyboard', to: redirect('/courses/getting-started-on-a-computer/lessons/the-keyboard')
  match '/learn/getting-started-computer/mouse', to redirect('/courses/getting-started-on-a-computer/lessons/the-mouse')
  match '/learn/getting-started-computer/what-computer', to: redirect('/courses/getting-started-on-a-computer/lessons/what-is-a-computer')
  match '/learn/intro-email/compose-and-send', to: redirect('/courses/intro-to-email/lessons/compose-and-send')
  match '/learn/basic-search', to: redirect('/courses/basic-search')
  match '/learn/basic-search/ads-search-results', to: redirect('/courses/basic-search/lessons/ads-in-search-results')
  match '/learn/basic-search/what-search-engine', to: redirect('/courses/basic-search/lessons/what-is-a-search-engine')
  match '/learn/buying-plane-ticket', to: redirect('/courses/buying-a-plane-ticket')
  match '/learn/cloud-storage', to: redirect('/courses/cloud-storage')
  match '/learn/cloud-storage/googledrive-and-skydrive', to: redirect('/courses/cloud-storage/lessons/google-drive-and-skydrive')
  match '/learn/cloud-storage/introduction-dropbox', to: redirect('/courses/cloud-storage/lessons/dropbox')
  match '/learn/cloud-storage/sharing-cloud', to: redirect('/courses/cloud-storage/lessons/sharing')
  match '/learn/cloud-storage/what-cloud-storage', to: redirect('/courses/cloud-storage/lessons/what-is-cloud-storage')
  match '/learn/creating-resumes/what-resume', to: redirect('/courses/creating-resumes/lessons/what-is-a-resume')
  match '/learn/intro-email', to: redirect('/courses/intro-to-email')
  match '/learn/intro-email/log', to: redirect('/courses/intro-to-email/lessons/logging-in')
  match '/learn/intro-email/open-messages-and-reply', to: redirect('/courses/intro-to-email/lessons/messages-and-replies')
  match '/learn/intro-email/quiz', to: redirect('/courses/intro-to-email/lessons/quiz')
  match '/learn/intro-email/sign-email', to: redirect('/courses/intro-to-email/lessons/sign-up-for-email')
  match '/learn/intro-email/what-email', to: redirect('/courses/intro-to-email/lessons/what-is-email')
  match '/learn/intro-facebook', to: redirect('/courses/intro-to-facebook')
  match '/learn/intro-facebook/finding-friends-facebook', to: redirect('/courses/intro-to-facebook/lessons/friends')
  match '/learn/intro-facebook/privacy-settings-facebook', to: redirect('/courses/intro-to-facebook/lessons/privacy')
  match '/learn/intro-facebook/setting-facebook-profile', to: redirect('/courses/intro-to-facebook/lessons/profiles')
  match '/learn/intro-facebook/status-updates-and-comments', to: redirect('courses/intro-to-facebook/lessons/posts-and-comments')
  match '/learn/intro-facebook/what-social-media', to: redirect('/courses/intro-to-facebook/lessons/why-facebook')
  match '/learn/intro-microsoft-word/learn/intro-microsoft-word', to: redirect('/courses/microsoft-word')
  match '/learn/intro-microsoft-word/cut-copy-paste', to: redirect('/learn/intro-microsoft-word/cut-copy-paste')
  match '/learn/intro-microsoft-word/intro-word', to: redirect('/courses/microsoft-word/lessons/introduction-cb8925aa-693e-4a82-82e4-f0c339fccad4')
  match '/learn/navigating-website', to: redirect('/courses/navigating-a-website')
  match '/learn/navigating-website/finding-website', to: redirect('/courses/navigating-a-website/lessons/finding-a-site')
  match '/learn/navigating-website/introduction', to: redirect('/courses/navigating-a-website/lessons/introduction-87a299c6-d872-490c-9673-bdd44a05f416')
  match '/learn/navigating-website/parts-website', to: redirect('/courses/navigating-a-website/lessons/parts-of-a-site')
  match '/learn/online-job-searching', to: redirect('/courses/online-job-searching')
  match '/learn/using-mac-os-x-0', to: redirect('/courses/using-a-mac-os-x')
  match '/learn/using-mac-os-x/deleting', to: redirect('/courses/using-a-mac-os-x/lessons/deleting')
  match '/learn/using-mac-os-x/desktop', to: redirect('/courses/using-a-mac-os-x/lessons/desktop')
  match '/learn/using-mac-os-x/files-and-folders', to: redirect('/courses/using-a-mac-os-x/lessons/files-and-folders')
  match '/learn/using-mac-os-x/saving-and-closing', to: redirect('/courses/using-a-mac-os-x/lessons/saving-and-closing')
  match '/learn/using-mac-os-x/using-window', to: redirect('/courses/using-a-mac-os-x/lessons/using-windows')
  match '/learn/using-mac-os-x/what-operating-system', to: redirect('/courses/using-a-mac-os-x/lessons/operating-systems')
  match '/learn/using-pc-windows-7', to: redirect('/courses/using-a-pc-windows-7')
  match '/learn/using-pc-windows-7/deleting', to: redirect('/courses/using-a-pc-windows-7/lessons/deleting-00c3d7bd-08a0-4fa9-8ed6-983ebafe8f9c')
  match '/learn/using-pc-windows-7/desktop', to: redirect('/courses/using-a-pc-windows-7/lessons/desktop-ee99c258-c10a-49f2-b046-915b339aed58')
  match '/learn/using-pc-windows-7/files-and-folders', to: redirect('/courses/using-a-pc-windows-7/lessons/files-and-folders-ba05484a-96d9-456c-b872-f150bd2f3ed5')
  match '/learn/using-pc-windows-7/saving-and-closing', to: redirect('/courses/using-a-pc-windows-7/lessons/saving-and-closing-030d2785-b289-4612-a032-83251c911764')
  match '/learn/using-pc-windows-7/using-window', to: redirect('/courses/using-a-pc-windows-7/lessons/using-windows-8252b6fc-d896-464d-92bd-06f00f9cb2bd')
  match '/learn/using-pc-windows-7/what-windows', to: redirect('/courses/using-a-pc-windows-7/lessons/what-is-windows')
  match '/learn/getting-started-computer/ports', to: redirect('/courses/getting-started-on-a-computer/lessons/ports-9af76a46-c0b7-485a-9422-bcb32f624f8a')
  # ~~~ End of redirect matchers ~~~ #
end
