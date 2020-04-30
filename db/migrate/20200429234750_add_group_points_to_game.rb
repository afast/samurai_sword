class AddGroupPointsToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :samurai_points, :integer
    add_column :games, :ninja_points, :integer
    add_column :games, :ronin_points, :integer
  end
end
