Rails.application.routes.draw do
  root 'home#index'

  resources :homes, only: [:index]

  namespace :api, defaults: { format: :json } do
    resources :operational_status,only: [] do
      collection do
        get 'projects_crawl_status'
      end
    end

  end


end
