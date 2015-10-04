Rails.application.routes.draw do
  root 'home#index'

  resources :homes, only: [:index]
end
