class CreateGamesUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :games_users do |t|
      t.integer :user_id
      t.integer :game_id
    end
  end
end
