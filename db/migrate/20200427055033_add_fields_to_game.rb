class AddFieldsToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :amount_players, :integer
    add_column :games, :players, :text
    add_column :games, :users, :text
    add_column :games, :hand, :integer
    add_column :games, :turn, :integer
    add_column :games, :phase, :integer
    add_column :games, :log, :text
    add_column :games, :wait_for_answer, :boolean
    add_column :games, :target, :text
    add_column :games, :game_ended, :boolean
  end
end
