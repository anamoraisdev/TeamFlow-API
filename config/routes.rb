Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "signup", to: "registrations#create"
      post "login", to: "sessions#create"

      resources :teams, only: %i[index create show update destroy] do
        resources :memberships, only: %i[index create update destroy], controller: "team_memberships"
        resources :projects, only: %i[index create]
        resources :audit_logs, only: %i[index]
      end

      resources :projects, only: %i[show update destroy] do
        resources :tasks, only: %i[index create]
      end

      resources :tasks, only: %i[show update destroy]
    end
  end
end
