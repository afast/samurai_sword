class AddPendingFieldsToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :pending_answer, :text
    add_column :games, :last_action, :string
  end
end
