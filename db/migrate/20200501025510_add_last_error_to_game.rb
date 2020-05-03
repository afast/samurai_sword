class AddLastErrorToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :last_error, :text
  end
end
