Rails.application.routes.draw do
  root 'courses#index'

  mount Ckeditor::Engine => '/ckeditor'
  resource :account, only: [:show, :update]
  resource :profile, only: [:show, :update] do
    post 'select_program'
    post 'get_schools_for_organization'
    get 'get_user_school'
    get 'get_program_data'
  end

  get '/invalid_profile', to: 'profiles#invalid_profile', as: :invalid_profile

  namespace :ajax do
    post 'programs/sub_programs'
    post 'programs/select_program'
  end

  resources :contacts, only: [:new, :create]

  get 'home_language_toggle', to: 'home#language_toggle'

  resources :courses, only: [:index, :show] do
    post 'start'
    get 'attachment/:attachment_id' => 'courses#view_attachment', as: :attachment
    get 'skills', to: 'courses#skills', as: :skills
    resources :lessons, only: [:index, :show] do
      get 'lesson_complete'
      post 'complete'
    end
  end

  resources :my_courses, only: [:index], param: :course_id

  resources :course_progresses, only: [:create, :update], param: :course_id

  resources :course_completions, only: [:index], param: :course_id
  # redirect previous course completion url to new url for GA Goal completion conversion
  get '/courses/:course_id/complete', to: 'course_completions#show', as: :course_completion

  resources :quiz_responses, only: [:new, :create]

  resources 'cms_pages', only: [:show]

  get '/static/customization', to: redirect('/cms_pages/pricing-features')
  get '/static/portfolio', to: redirect('/cms_pages/see-our-work-in-action')
  get '/static/overview', to: redirect('/cms_pages/get-digitallearn-for-your-library')

  get 'designing-courses-1', to: 'courses#designing_courses_1'
  get 'designing-courses-2', to: 'courses#designing_courses_2'

  namespace :trainer do
    root 'home#index'
    resources :dashboard, only: [:index]
  end

  namespace :admin do
    root 'dashboard#index'
    put 'lessons/sort', to: 'lessons#sort'
    resources :organizations, only: [:new, :create, :index, :update], path: 'subsites'
    resources :library_locations do
      put :sort, on: :collection
    end
    resource :reports, only: [:show]
    resource :report_export, only: [:show]
    resource :completion_report, only: [:show]

    resources :programs, only: [:new, :create, :index, :edit] do
    end

    resources :categories, only: [:create, :index] do
      put :sort, on: :collection
      post 'toggle'
    end

    resources :partners, only: [:index, :create, :destroy]

    resources :program_locations, only: [:create] do
      post 'toggle'
    end

    resources :schools, only: [:create, :index] do
      post 'toggle'
    end

    resources :dashboard, only: [:index]
    resources :users, only: [:index]
    resources :pages, only: [:index]

    get 'dashboard/import_courses', to: 'dashboard#import_courses', as: :import_courses
    post 'dashboard/add_imported_course', to: 'dashboard#add_imported_course'

    resources :cms_pages, except: :show do
      put :sort, on: :collection
      patch 'update_pub_status'
    end

    patch 'users/:id/change_user_roles', to: 'users#change_user_roles', as: :change_user_roles

    get 'users/export_user_info', to: 'users#export_user_info', as: :export_user_info

    resources :courses, except: [:show] do
      put :sort, on: :collection
      patch 'update_pub_status'
      get :preview

      resources :lessons, except: [:index, :show] do
        collection do
          delete :destroy_asl_attachment
        end
      end
    end

    resources :attachments, only: [:destroy]

    namespace :custom do
      resources :translations, constraints: { :id => /[^\/]+/ }
      resource :footers, only: [:show, :update]
      resource :user_surveys, only: [:show, :update]
      resource :features, only: [:show, :update]
      resource :programs, only: [:show, :update]
      resource :branches, only: [:show, :update]
    end

  end

  devise_for :users, controllers: {
    registrations: 'registrations',
    invitations: 'admin/invites',
    sessions: 'sessions',
    passwords: 'passwords'
  }, path_names: {
    sign_up: ''
  }

  devise_scope :user do
    get 'login/new', to: 'sessions#new', as: :login
  end
  
  get 'users/invitation/accept', to: 'devise/invitations#edit'

  match '/404', to: 'errors#error404', via: [:get, :post, :patch, :delete]
  match '/500', to: 'errors#error500', via: [:get, :post, :patch, :delete]

  # These are all the redirects needed to keep things working from the old site.
  # They are coming from links on external sites that we can't update or change.
  # Please don't delete them.
  # ~~~ Start of redirect matchers ~~~ #
  get '/learn', to: redirect('/courses')
  get '/teach', to: redirect('https://training.digitallearn.org')
  get '/teach/*path', to: redirect('https://training.digitallearn.org')
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
