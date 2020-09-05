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
      post :play_counter_stop
      post :kote_selected_player
      post :discard_weapon
      post :defend_bushido
      post :hanzo_ability
      post :kanbei_ability
      post :ieyasu_take_cards
      post :nobunaga_take_card
      post :propose_for_intuicion
      post :steal_by_intuicion
      post :shima_ability
      post :okuni_ability
    end
  end

  resources :users
  mount ActionCable.server, at: '/cable'
end
