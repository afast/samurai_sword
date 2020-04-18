class Player
  attr_accessor :role, :character, :honor, :resistance, :user, :cards

  def initialize(role, character, user, amount_players)
    raise "Error, player must have a valid role" unless role.is_a?(Role)
    raise "Error, player must have a valid character" unless character.is_a?(Character)
    @role = role
    @user = user
    @character = character
    initialize_honor(amount_players)
    reset_resistance
  end

  def initialize_honor(amount_players)
    @honor = role.initial_honor(amount_players)
  end

  def initial_resistance
    character.resistance
  end

  def reset_resistance
    @resistance = initial_resistance
  end

  def inoffensive
    cards.none? && resistance.zero?
  end
end
