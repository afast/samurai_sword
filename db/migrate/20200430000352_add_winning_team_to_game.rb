class AddWinningTeamToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :winning_team, :string
  end
end
