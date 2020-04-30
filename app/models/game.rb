class Game < ApplicationRecord
  STATUS = {
    waiting: 'WAITING',
    started: 'STARTED',
    ended: 'ENDE'
  }

  has_and_belongs_to_many :users

  attr_accessor :amount_players, :players, :deck, :discarded, :hand, :turn, :phase, :log, :wait_for_answer, :target, :game_ended, :samurai_points, :ninja_points,
                :ronin_points, :winning_team

  CHARACTERS = [:benkei, :chiyome, :ginchiyo, :goemon, :hanzo, :hideyoshi, :ieyasu, :kojiro, :musashi, :nobunaga, :tomoe, :ushiwaka]
  INITIAL_AMOUNT_CARDS = [4, 5, 5, 6, 6, 7, 7]

  after_initialize do |game|
    game.status = STATUS[:waiting] unless game.status
    game.save
  end

  def determine_roles(amount)
    raise "Error, there should be 4-7 players, #{amount} is an invalid number of players" unless amount >= 2 && amount <= 7
    roles = [Shogun.new, Ninja.new]

    case amount
    when 3
      roles << Samurai.new
    when 4
      roles << Ninja.new
    when 5
      roles << Ronin.new
    when 6
      roles += [Ronin.new, Ninja.new]
    when 7
      roles += [Ronin.new, Ninja.new, Samurai.new]
    end
    roles.shuffle
  end

  def initialize_players
    player_set = CHARACTERS.shuffle.take(@amount_players).zip(determine_roles(@amount_players))
    i=-1
    player_set.map do |character, role|
      i = i+1
      @turn = i if role.is_a?(Shogun)
      char = character.to_s.capitalize.constantize.new
      Player.new(role, char, users[i], @amount_players)
    end
  end

  def initialize_cards
    Card.initialize_weapons.shuffle
  end

  def start
    @amount_players = users.size
    @players = initialize_players
    @deck = initialize_cards
    @game_ended = false
    @log = []
    @phase = 2
    i = 0
    while i < @players.size do
      @players[(@turn + i) % @players.size].cards = @deck.slice!(0, INITIAL_AMOUNT_CARDS[i])
      i+= 1
    end
    @discarded = []
    @hand = 0
    update_attributes status: STATUS[:started], amount_players: @amount_players, players: @players, deck: @deck, game_ended: false, phase: 2, discarded: @discarded, hand: 0
  end

  def current_state
    if @game_ended
      "Game Ended"
    else
      "#{current_player.character} - #{current_player.role} | Phase #{@phase}"
    end
  end

  def current_player
    @players[@turn]
  end

  def handle_deck_zero
    @deck = @discarded.shuffle
    @discarded = []
    @players.map { |p| p.honor -= 1 }
    handle_game_end
  end

  def handle_game_end
    @game_ended = @players.collect(&:dead?).inject(:|)
    @samurai_points = 0
    @ninja_points = 0
    @ronin_points = 0
    first_ninja=true
    @players.each do |p|
      case p.role
      when Shogun
        @samurai_points += p.honor
      when Samurai
        @samurai_points += (@amount_players % 2 == 0) ? p.honor*2 : p.honor
      when Ninja
        if @amount_players == 4 && first_ninja
          @ninja_points += p.honor*2
        else
          @ninja_points += p.honor
        end
      when Ronin
        if @amount_players == 5
          @ronin_points = p.honor*2
        elsif @amount_players > 5
          @ronin_points = p.honor*3
        end
      end
    end

    if @samurai_points > @ninja_points && @samurai_points >= @ronin_points
      @winning_team = 'Shogun/Samurais'
    elsif @ninja_points >= @samurai_points && @ninja_points >= @ronin_points
      @winning_team = 'Ninjas'
    else
      @winning_team = 'Ronin'
    end
  end

  def draw_cards(player, amount)
    return if @game_ended
    player.cards += @deck.slice!(0, amount)
    handle_deck_zero if @deck.size.zero?
  end

  def process_phase
    return if @game_ended
    if @phase == 1
      if current_player.resistance.zero?
        current_player.reset_resistance
      end
    end
    case @phase
    when 2
      @hand += 1 if current_player.role.is_a? Shogun
      draw_cards(current_player, 2)
    when 4
      if current_player.cards.size > 7
        @discarded += current_player.cards.slice!(7, Card::WEAPONS.size)
      end
      current_player.cleanup_turn
      next_turn
      next_phase unless current_player.resistance.zero?
    end
    next_phase
  end

  def next_turn
    return if @game_ended
    @turn = (@turn + 1) % @amount_players
  end

  def find_player_by_character(character)
    @players.detect { |p| p.character.to_s.downcase == character.downcase }
  end

  def play_card(source_player, card_name, target_player)
    return if @game_ended
    current_player = find_player_by_character(source_player)
    target = find_player_by_character(target_player)
    target_index = @players.index(target)
    card_index = current_player.cards.index { |c| c.name.to_s == card_name.downcase }
    card = current_player.cards[card_index]
    raise "Error, no player for index" unless target
    case card.type
    when Card::WEAPON
      raise "Error, player can't play another weapon" unless current_player.can_play_weapon?
      raise "Error, player is inoffensive" if target.inoffensive
      raise "Error, player too far away" if current_player.distance(@turn, target_index, self) > card.distance
      if target.can_defend?
        wait = true
        @game.wait_for_answer = true
        @game.target = target
      else
        wait = false
        target.take_damage(card.damage, current_player)
      end
      @discarded << current_player.cards.delete_at(card_index)
      current_player.weapons_played = 1
      @log << { card: card, target: target, wait_for_answer: wait }
      handle_game_end
    when Card::PROPERTY
    when Card::ACTION
    end
  end

  def reset_resistance_for_current_player
    current_player.reset_resistance
  end

  def next_phase
    return if @game_ended
    case @phase
    when 1
      @phase = 2
    when 2
      @phase = 3
    when 3
      @phase = 4
    when 4
      @phase = 1
    end
  end
end
