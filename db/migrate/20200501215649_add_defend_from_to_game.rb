class AddDefendFromToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :defend_from, :text
  end
end
