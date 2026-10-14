Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  defaults format: :json do
    namespace :auth do
      post "login", to: "auth#login"
      post "logout", to: "auth#destroy_auth"
      get "current_user", to: "auth#show_current_user"
      get "email_exists", to: "auth#email_exists"
    end

    post 'users/create', to: "users#create"
  end
end
