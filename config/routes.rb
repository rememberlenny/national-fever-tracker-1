 # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :tracker_reminders, only: [:new, :create]
  resources :temperature_checks, only: [:new, :create]

  match "/unsubscribe", via: :all, to: "temperature_checks#unsubscribe", as: :unsubscribe
  
  # Jumpstart views
  if Rails.env.development? || Rails.env.test?
    mount Jumpstart::Engine, at: '/jumpstart'
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['BLAZER_USERNAME'] && password == ENV['BLAZER_PASSWORD']
  end
  mount Sidekiq::Web => '/sidekiq'
  mount Blazer::Engine, at: "blazer"

  # # Administrate
  # authenticated :user, lambda { |u| u.admin? } do
  #   namespace :admin do
  #     if defined?(Sidekiq)
  #     end

  #     resources :announcements
  #     resources :users
  #     namespace :user do
  #       resources :connected_accounts
  #     end
  #     resources :teams
  #     resources :team_members
  #     resources :plans
  #     namespace :pay do
  #       resources :charges
  #       resources :subscriptions
  #     end

  #     root to: "dashboard#show"
  #   end
  # end

  # # API routes
  # namespace :api, defaults: { format: :json } do
  #   namespace :v1 do
  #     resource :me, controller: :me
  #     resources :teams
  #     resources :users
  #   end
  # end

  # # User account
  # devise_for :users,
  #            controllers: {
  #              masquerades: 'jumpstart/masquerades',
  #              omniauth_callbacks: 'users/omniauth_callbacks',
  #              registrations: 'users/registrations',
  #            }

  # resources :announcements, only: [:index]
  # resources :api_tokens
  # resources :teams do
  #   member do
  #     patch :switch
  #   end

  #   resources :team_members, path: :members
  #   resources :team_invitations, path: :invitations, module: :teams
  # end
  # resources :team_invitations

  # # Payments
  # resource :card
  # resource :subscription do
  #   patch :info
  #   patch :resume
  # end
  # resources :charges
  # namespace :account do
  #   resource :password
  # end

  # namespace :users do
  #   resources :mentions, only: [:index]
  # end
  # namespace :user, module: :users do
  #   resources :connected_accounts
  # end

  # resources :embeds, only: [:create], constraints: { id: /[^\/]+/ } do
  #   collection do
  #     get :patterns
  #   end
  # end

  scope controller: :static do
    get :about
    get :map
    get :thank_you
    get :faq
    get :terms
    get :privacy
    get :pricing
  end

  match "/404", via: :all, to: "errors#not_found"
  match "/500", via: :all, to: "errors#internal_server_error"

  authenticated :user do
    root to: "dashboard#show", as: :user_root
  end

  # Public marketing homepage
  root to: "temperature_checks#new"
end
