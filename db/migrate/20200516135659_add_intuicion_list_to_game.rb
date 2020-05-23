class AddIntuicionListToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :intuicion_list, :text
  end
end
