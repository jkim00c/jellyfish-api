Rails.application.routes.draw do
  # Docs
  apipie

  # Auth
  devise_for :staff, controllers: { sessions: 'sessions' }

  # Alerts Routes
  resources :alerts, defaults: { format: :json } do
    collection do
      post :sensu
    end
  end

  # User Setting Options Routes
  resources :user_setting_options, defaults: { format: :json }

  # Approvals
  resources :staff, defaults: { format: :json, methods: %w(gravatar) }, only: [:index]
  resources :staff, defaults: { format: :json }, only: [:show, :create, :update, :destroy] do
    # Staff Orders
    resources :orders, controller: 'staff_orders', defaults: { format: :json, includes: %w(order_items) }, only: [:show, :index]

    collection do
      match 'current_member' => 'staff#current_member', via: :get, defaults: { format: :json }
    end

    member do
      match 'settings' => 'staff#user_settings', :via => :get, as: :user_settings_for
      match 'settings' => 'staff#add_user_setting', :via => :post, as: :add_user_setting_to
      match 'settings/:user_setting_id' => 'staff#show_user_setting', :via => :get
      match 'settings/:user_setting_id' => 'staff#update_user_setting', :via => :put
      match 'settings/:user_setting_id' => 'staff#remove_user_setting', :via => :delete, as: :remove_user_setting_from
      get :projects, to: 'staff#projects', as: :projects_for
      match 'projects/:project_id' => 'staff#add_project', :via => :post, as: :add_project_to
      match 'projects/:project_id' => 'staff#remove_project', :via => :delete, as: :remove_project_from
    end
  end

  # Approvals
  resources :approvals, except: [:edit, :new], defaults: { format: :json }

  # Organizations
  resources :organizations, except: [:edit, :new], defaults: { format: :json }

  # Provision Request Response
  resources :order_items, defaults: { format: :json }, only: [:update] do
    member do
      put :provision_update
    end
  end

  # Orders
  resources :orders, except: [:edit, :new], defaults: { format: :json, includes: %w(order_items) } do
    # Order Items
    resources :items, controller: 'order_items', except: [:index, :edit, :new, :create], defaults: { format: :json, includes: [] } do
      member do
        put :start_service
        put :stop_service
      end
    end
  end

  # Products
  resources :products, except: [:edit, :new], defaults: { format: :json } do
    member do
      get :answers
    end
  end

  # ProductTypes
  resources :product_types, except: [:edit, :new], defaults: { format: :json } do
    member do
      get :questions
    end
  end

  # Chargebacks
  resources :chargebacks, except: [:edit, :new], defaults: { format: :json }

  # Clouds
  resources :clouds, except: [:edit, :new], defaults: { format: :json }

  # Project Routes
  resources :projects, defaults: { format: :json, includes: %w(project_answers services), methods: %w(domain url state state_ok problem_count account_number resources resources_unit icon cpu hdd ram status monthly_spend users order_history) }, only: [:show]
  resources :projects, defaults: { format: :json, methods: %w(domain url state state_ok problem_count account_number resources resources_unit icon cpu hdd ram status monthly_spend) }, only: [:index]
  resources :projects, defaults: { format: :json }, except: [:index, :show, :edit, :new] do
    member do
      get :staff, to: 'projects#staff', as: :staff_for
      match 'staff/:staff_id' => 'projects#add_staff', :via => :post, as: :add_staff_to
      match 'staff/:staff_id' => 'projects#remove_staff', :via => :delete, as: :remove_staff_from
      match 'approve' => 'projects#approve', :via => :put, as: :approve_project
      match 'reject' => 'projects#reject', :via => :put, as: :reject_project
    end
  end

  # ProjectQuestion Routes
  resources :project_questions, except: [:edit, :new], defaults: { format: :json }

  # Admin Settings
  resources :settings, defaults: { format: :json, includes: %w(setting_fields)  }, only: [:index, :update, :show, :edit, :new, :destroy]
  resources :settings, defaults: { format: :json, includes: %w(setting_fields)  }, only: [:show], param: :name

  # Automate Routes
  get 'automate/catalog_item_initialization', to: 'automate#catalog_item_initialization'
  get 'automate/update_servicemix_and_chef', to: 'automate#update_servicemix_and_chef'
  get 'automate/create_rds', to: 'automate#create_rds'
  get 'automate/provision_rds', to: 'automate#provision_rds'
  get 'automate/create_ec2', to: 'automate#create_ec2'
  get 'automate/create_s3', to: 'automate#create_s3'
  get 'automate/create_ses', to: 'automate#create_ses'
  get 'automate/retire_ec2', to: 'automate#retire_ec2'
  get 'automate/retire_rds', to: 'automate#retire_rds'
  get 'automate/retire_s3', to: 'automate#retire_s3'
  get 'automate/retire_ses', to: 'automate#retire_ses'
  get 'automate/create_vmware_vm', to: 'automate#create_vmware_vm'
  get 'automate/retire_vmware_vm', to: 'automate#retire_vmware_vm'

  root 'welcome#index'

  # # Dashboard Routes
  # resources :dashboard
  #
  # # Manage Routes
  # resources :manage
  #
  # # Marketplace Routes
  # resources :marketplace
  #
  # # Service Routes
  # resources :service

  # Mocks routes
  # TODO: Remove when implemented
  get 'applications/:id', to: 'mocks#application', defaults: { format: :json }
  get 'applications', to: 'mocks#applications', defaults: { format: :json }
  get 'bundles/:id', to: 'mocks#bundle', defaults: { format: :json }
  get 'bundles', to: 'mocks#bundles', defaults: { format: :json }
  get 'services/:id', to: 'mocks#service', defaults: { format: :json }
  get 'services', to: 'mocks#services', defaults: { format: :json }
  get 'solutions/:id', to: 'mocks#solution', defaults: { format: :json }
  get 'solutions', to: 'mocks#solutions', defaults: { format: :json }
  get 'alerts', to: 'mocks#alerts', defaults: { format: :json }
  get 'alertPopup', to: 'mocks#alert_popup', defaults: { format: :json }
  get 'header', to: 'mocks#header', defaults: { format: :json }
  get 'manage', to: 'mocks#manage', defaults: { format: :json }
  get 'marketplaceValues', to: 'mocks#marketplace', defaults: { format: :json }
  get 'new-project', to: 'mocks#new_project', defaults: { format: :json }
end
