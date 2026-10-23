Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  defaults format: :json do
    namespace :auth do
      post "login", to: "auth#login"
      post "logout", to: "auth#destroy_auth"
      get "current_user", to: "auth#show_current_user"
      get "email_exists", to: "auth#email_exists"
    end

    resources :users, only: [:create, :update, :show, :index] do
      collection do
        post "signup", to: "users#signup"
      end
    end

    resources :profiles, only: [:update, :show]
  end
end
