Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      
      post 'auth/register', to: 'auth#register'
      get 'auth/confirm_email', to: 'auth#confirm_email'
      put 'auth/update_password', to: 'auth#update_password'
      post 'auth/login', to: 'auth#login' 
      post 'auth/google_login', to: 'auth#google_login'
      post 'auth/refresh', to: 'auth#refresh'
      delete 'auth/logout', to: 'auth#logout'
      delete 'auth/logout_all', to: 'auth#logout_all'
        
      resources :password_resets, only: [:create, :update]

      get 'users/me', to: 'users#me'
      patch 'users/update_profile', to: 'users#update_profile'

      resources :projects do
        resources :tasks, only: [:index, :create] do
          collection do
            patch :reorder
          end
        end
      end
      
      resources :tasks, only: [:show, :update, :destroy]
    end
  end
end
