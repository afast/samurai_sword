class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.integer :num_players
      t.boolean :waiting_room
      t.boolean :started
      t.boolean :ended
      t.text :deck
      t.text :discarded

      t.timestamps
    end
  end
end
