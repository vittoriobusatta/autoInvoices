Rails.application.routes.draw do
  get 'webhooks/receive'
  namespace :api do
    namespace :v1 do
      resources :upload, only: [:create]
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
