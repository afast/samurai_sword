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
      post :discard_card
      post :reset_resistance
      get :admin
      post :start
      post :join
      post :take_damage
      post :play_stop
      post :discard_weapon
      post :defend_bushido
      post :hanzo_ability
      post :ieyasu_take_cards
      post :nobunaga_take_card
    end
  end

  resources :users
  mount ActionCable.server, at: '/cable'
end
