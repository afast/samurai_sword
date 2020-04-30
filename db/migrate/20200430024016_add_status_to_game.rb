class AddStatusToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :status, :string
  end
end
