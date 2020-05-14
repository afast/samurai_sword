class AddExtensionToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :extension, :boolean
  end
end
