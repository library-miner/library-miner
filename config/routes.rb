Rails.application.routes.draw do
  root 'home#index'

  resources :homes, only: [:index]

  namespace :api, defaults: { format: :json } do
    resources :admin,only: [] do
      collection do
      end
    end

  end


end
