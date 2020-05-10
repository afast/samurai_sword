class AddBushidoToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :resolve_bushido, :boolean
    add_column :games, :bushido_in_play, :boolean
  end
end
