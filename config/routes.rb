Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  root to: 'games#index'
  resources :games do
    member do
      post :take_cards
      post :play_card
      post :answer_card
      post :end_turn
      post :discard_cards
      post :reset_resistance
      get :admin
      post :start
      post :join
    end
  end

  resources :users
end
