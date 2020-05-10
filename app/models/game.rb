class Game < ApplicationRecord
  STATUS = {
    waiting: 'WAITING',
    started: 'STARTED',
    ended: 'ENDE'
  }

  has_and_belongs_to_many :users

  attr_accessor :amount_players, :hand, :turn, :phase, :wait_for_answer, :game_ended, :samurai_points, :ninja_points,
                :ronin_points, :winning_team
  attr_accessor :players, :deck, :discarded, :pending_answer, :target, :defend_from, :log, :resolve_bushido, :bushido_in_play

  serialize :players
  serialize :deck
  serialize :discarded
  serialize :log
  serialize :target
  serialize :users
  serialize :pending_answer
  serialize :defend_from

  CHARACTERS = [:benkei, :chiyome, :ginchiyo, :goemon, :hanzo, :hideyoshi, :ieyasu, :kojiro, :musashi, :nobunaga, :tomoe, :ushiwaka]
  INITIAL_AMOUNT_CARDS = [4, 5, 5, 6, 6, 7, 7]

  after_initialize do |game|
    game.status = STATUS[:waiting] unless game.status
  end

  def determine_roles(amount)
    raise "Error, there should be 4-7 players, #{amount} is an invalid number of players" unless amount >= 2 && amount <= 7
    roles = [Shogun.new, Ninja.new]

    case amount
    when 3
      roles << Ninja.new
    when 4
      roles += [Ninja.new, Samurai.new]
    when 5
      roles += [Ninja.new, Samurai.new, Ronin.new]
    when 6
      roles += [Ninja.new, Samurai.new, Ronin.new, Ninja.new]
    when 7
      roles += [Ninja.new, Samurai.new, Ronin.new, Ninja.new, Samurai.new]
    end
    roles.shuffle
  end

  def initialize_players
    player_set = CHARACTERS.shuffle.shuffle.shuffle.take(@amount_players).zip(determine_roles(@amount_players))
    i=-1
    player_set.map do |character, role|
      i = i+1
      @turn = i if role.is_a?(Shogun)
      char = character.to_s.capitalize.constantize.new
      Player.new(role, char, users[i], @amount_players)
    end
  end

  def initialize_cards
    Card.initialize_cards.shuffle
  end

  def start
    return unless self.status == STATUS[:waiting]
    @amount_players = users.size
    @players = initialize_players
    @deck = initialize_cards
    @resolve_bushido = false
    @bushido_in_play = false
    @game_ended = false
    @log = [{player: 'System', message: 'Inicio del Juego', type: :info}]
    @phase = 2
    i = 0
    while i < @players.size do
      @players[(@turn - i) % @players.size].cards = @deck.slice!(0, INITIAL_AMOUNT_CARDS[i])
      i+= 1
    end
    @discarded = []
    @hand = 0
    update status: STATUS[:started], amount_players: @amount_players, players: @players, deck: @deck, game_ended: false, phase: 2, discarded: @discarded, hand: 0
  end

  def discard_card(card_name)
    index = current_player.cards.index { |c| c.name.to_s.downcase == card_name  }
    @discarded << current_player.cards.delete_at(index)
    @log << { player: current_player.user.username, message: "Descartó #{card_name}", type: :info }
    update discarded: @discarded, users: users
    if current_player.cards.size <= 7
      next_phase
    end
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

  def all_other_players
    @players.slice(0, @turn) + @players.slice(@turn+1, @players.size-1)
  end

  def all_other_offensive_players
    all_other_players.select { |p| !p.inoffensive }
  end

  def handle_deck_zero
    @deck = @discarded.shuffle.shuffle.shuffle
    @discarded = []
    @players.map { |p| p.honor -= 1 }
    @log << { player: current_player.user.username, message: "Se acabo el mazo, todos pierden un punto de honor", type: :info }
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
        @samurai_points += p.honor + p.daimio_points
      when Samurai
        @samurai_points += (@amount_players % 2 == 0) ? p.honor*2 : p.honor
        @samurai_points += p.daimio_points
      when Ninja
        if @amount_players == 4 && first_ninja
          first_ninja = false
          @ninja_points += p.honor*2
        else
          @ninja_points += p.honor
        end
        @ninja_points += p.daimio_points
      when Ronin
        if @amount_players == 5
          @ronin_points = p.honor*2
        elsif @amount_players > 5
          @ronin_points = p.honor*3
        end
      end
    end

    if current_player.samurai_team? && @players.select(&:dead?).collect(&:samurai_team?).inject(:|)
      @samurai_points -= 3
    elsif current_player.ninja_team? && @players.select(&:dead?).collect(&:samurai_team?).inject(:|)
      @ninja_points -= 3
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
    remaining = @deck.size < amount ? amount - @deck.size : 0
    player.cards += @deck.slice!(0, amount)
    handle_deck_zero if @deck.size.zero?
    player.cards += @deck.slice!(0, remaining) if remaining > 0
  end

  def draw_card_from_discard(player, amount)
    return if @game_ended || @discarded.none?
    player.cards += @discarded.slice!(@discarded.size-1, 1)
  end

  def ieyasu_take_cards
    return if @game_ended || @phase != 2 || !current_player.character.is_a?(Ieyasu) || @discarded.none?
    update(last_action: nil, last_error: nil)
    @hand += 1 if current_player.role.is_a? Shogun
    current_player.weapons_played = 0
    draw_card_from_discard(current_player, 1)
    amount = current_player.draw_card_amount - 1
    amount += 1 if players.size == 3 && current_player.role.is_a?(Shogun)
    draw_cards(current_player, amount)
    @log << { player: current_player.user.username, message: "Robo 2 cartas. (1 del monto de descarte)", type: :info }
    next_phase
  end

  def nobunaga_take_card
    return if @game_ended || !current_player.character.is_a?(Nobunaga) || current_player.resistance <= 1
    update(last_action: nil, last_error: nil)
    draw_cards(current_player, 1)
    current_player.resistance -= 1
    @log << { player: current_player.user.username, message: "Nobunaga roba 1 carta adicional por 1 de daño", type: :info }
  end

  def process_phase
    return if @game_ended
    update(last_action: nil, last_error: nil)
    if @phase == 1
      if current_player.resistance <= 0
        current_player.reset_resistance
        @log << { player: current_player.user.username, message: "Recupero Resistencia", type: :info }
      end
    end
    case @phase
    when 2
      @hand += 1 if current_player.role.is_a? Shogun
      current_player.weapons_played = 0
      amount = current_player.draw_card_amount
      amount += 1 if players.size == 3 && current_player.role.is_a?(Shogun)
      draw_cards(current_player, amount)
      @log << { player: current_player.user.username, message: "Robo 2 cartas", type: :info }
    when 4
      if current_player.cards.size > 7
        @discarded += current_player.cards.slice!(7, Card::WEAPONS.size)
      end
      current_player.cleanup_turn
      next_turn
      next_phase unless current_player.resistance <= 0
    end
    next_phase
  end

  def next_turn
    return if @game_ended
    @log << { player: current_player.user.username, message: "Finalizo Turno", type: :info }
    @turn = (@turn - 1) % @amount_players
    @log << { player: current_player.user.username, message: "Comienzo Turno", type: :info }
    update(last_action: nil, last_error: nil, log: @log)
  end

  def find_player_by_character(character)
    @players.detect { |p| p.character.to_s.downcase == character.downcase }
  end

  def play_card(source_player, card_name, target_player, what_card)
    return if @game_ended
    @last_action = nil
    @last_error = nil
    current_player = find_player_by_character(source_player)
    if target_player
      target = find_player_by_character(target_player)
      target_index = @players.index(target)
    end
    card_index = current_player.cards.index { |c| c.name.to_s == card_name.downcase }
    card = current_player.cards[card_index]
    case card.type
    when Card::WEAPON
      @last_error = "Error, no player for index" unless target
      @last_error = "Error, #{current_player.user.username} no puede jugar mas armas" unless current_player.can_play_weapon?(@players.size)
      @last_error = "Error, #{target.user.username} esta inofensivo" if target.inoffensive
      @last_error = "Error, #{target.user.username} esta demasiado lejos" if current_player.distance(@turn, target_index, self) > card.distance
      if @last_error
        @log << { player: current_player.user.username, message: @last_error, type: :error }
        update(last_error: @last_error, last_action: @last_action, log: @log)
        return
      end
      @pending_answer = []
      @discarded ||= []
      @wait_for_answer = true
      @pending_answer << target
      @last_action = "#{current_player.user.username} atacó a #{target.user.username} con #{card.friendly_name} - Daño base: #{card.damage + current_player.damage_modifier} - esperando respuesta de #{target.user.username}"
      @log << { player: current_player.user.username, message: @last_action, type: :info }
      @target = target
      update(wait_for_answer: @wait_for_answer, defend_from: card, pending_answer: @pending_answer, last_action: @last_action, target: @target, log: @log)
      @discarded << current_player.cards.delete_at(card_index)
      update(discarded: @discarded)
      current_player.weapons_played += 1
      handle_game_end
    when Card::PROPERTY
      @defend_from = {}
      if card_name == 'bushido'
        if @bushido_in_play
          @log << { player: current_player.user.username, message: "Ya hay un Bushido en juego", type: :error }
        else
          target.visible_cards ||= []
          target.visible_cards << current_player.cards.delete_at(card_index)
          @bushido_in_play = true
          @last_action = "#{current_player.user.username} jugó #{card.friendly_name} a #{target.user.username}"
          @log << { player: current_player.user.username, message: @last_action, type: :info }
        end
      else
        current_player.visible_cards ||= []
        current_player.visible_cards << current_player.cards.delete_at(card_index)
        @last_action = "Bajó #{card.friendly_name} a la mesa"
        @log << { player: current_player.user.username, message: @last_action, type: :info }
        update(log: @log)
      end
    when Card::ACTION
      @defend_from = {}
      case card_name
      when 'respiracion'
        if target
          current_player.reset_resistance!
          draw_cards(target, 1)
          @last_action = "Respiracion - #{current_player.character} recupero resistencia y #{target.character} robo una carta"
          @log << { player: current_player.user.username, message: @last_action, type: :info }
          @discarded << current_player.cards.delete_at(card_index)
        else
          @last_error = "Error, debe elegir un jugador para recibir la carta"
          @log << { player: current_player.user.username, message: @last_error, type: :error }
        end
        update(discarded: @discarded, log: @log)
      when 'jiujitsu'
        @pending_answer = []
        @last_action = "Jugó Jiu-Jitsu, todos los demas descartan un arma o pierden 1 de resistencia"
        @log << { player: current_player.user.username, message: @last_action, type: :info }
        all_other_offensive_players.each do |p|
          @pending_answer << p
        end
        @discarded << current_player.cards.delete_at(card_index)
        update(discarded: @discarded, last_action: @last_action, defend_from: card, pending_answer: @pending_answer, log: @log)
        handle_game_end
      when 'grito_de_batalla'
        @pending_answer = []
        @last_action = "Jugó Grito de Batalla, todos los demas descartan una parada o pierden 1 de resistencia"
        @log << { player: current_player.user.username, message: @last_action, type: :info }
        all_other_offensive_players.each do |p|
          @pending_answer << p
        end
        @discarded << current_player.cards.delete_at(card_index)
        update(discarded: @discarded, last_action: @last_action, defend_from: card, pending_answer: @pending_answer, log: @log)
        handle_game_end
      when 'ceremonia_del_te'
        draw_cards(current_player, 3)
        all_other_players.each { |p| draw_cards(p, 1) }
        @last_action = "Jugó Ceremonia del Te, recibe 3 cartas y el resto reciben 1"
        @log << { player: current_player.user.username, message: @last_action, type: :info }
        @discarded << current_player.cards.delete_at(card_index)
        update(discarded: @discarded, deck: @deck, last_action: @last_action, log: @log)
      when 'distraccion'
        if target && target.cards.any?
          current_player.cards << target.cards.delete(target.cards.sample)
          @last_action = "Jugó Distracción, roba una carta al azar de la mano de #{target.user.username}"
          @log << { player: current_player.user.username, message: @last_action, type: :info }
          @discarded << current_player.cards.delete_at(card_index)
        else
          @last_error = "Error, debe elegir un jugador a quien robar la carta" unless target
          @last_error = "Error, el jugador no posee cartas" unless target.cards.any?
          @log << { player: current_player.user.username, message: @last_error, type: :error }
        end
        update(discarded: @discarded, last_action: @last_action, log: @log)
      when 'geisha'
        if target && (what_card == 'from_hand' && target.cards.any? || what_card != 'from_hand')
          @discarded << current_player.cards.delete_at(card_index)
          if what_card == 'from_hand'
            @discarded << target.cards.delete(target.cards.sample)
            @last_action = "Jugó Geisha, descartó (al azar) #{@discarded.last.friendly_name} de la mano de #{target.user.username}"
          else
            @discarded << target.visible_cards.delete_at(target.find_visible_card(what_card))
            if @discarded.last.bushido?
              @bushido_in_play = false
            end
            @last_action = "Jugó Geisha, descartó #{@discarded.last.friendly_name} de #{target.user.username}"
          end
          @log << { player: current_player.user.username, message: @last_action, type: :info }
        else
          @last_error = "Error, debe elegir un jugador a quien robar la carta" unless target
          @last_error = "Error, debe elegir un jugador con cartas" if what_card == 'from_hand' && target.cards.none?
          @log << { player: current_player.user.username, message: @last_eror, type: :error }
        end
        update(discarded: @discarded, last_action: @last_action, log: @log)
      when 'daimio'
        draw_cards(current_player, 2)
        @last_action = "Jugó Daimio, recibe 2 cartas"
        @log << { player: current_player.user.username, message: @last_action, type: :info }
        @discarded << current_player.cards.delete_at(card_index)
        update(discarded: @discarded, deck: @deck, last_action: @last_action, log: @log)
      end
    end
    save
  end

  def take_damage(character)
    if resolve_bushido
      current_player.honor -= 1 unless current_player.role.is_a?(Shogun) && players.size == 3
      @discarded << current_player.discard_bushido
      @log << { player: current_player.user.username, message: "Pierde 1 honor debido a Bushido", type: :info }
      @bushido_in_play = false
      @resolve_bushido = false
    else
      index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
      player_to_receive_damage = pending_answer.delete_at index
      @wait_for_answer = false if pending_answer.blank?
      @last_action = "#{player_to_receive_damage.user.username} recibe #{defend_from.damage + current_player.damage_modifier(defend_from)} de daño por #{defend_from.friendly_name}"
      @log << { player: current_player.user.username, message: @last_action, type: :info }
      if player_to_receive_damage.take_damage(defend_from.damage, current_player, defend_from)
        handle_action_after_damage(current_player, player_to_receive_damage, defend_from)
      end
    end
    handle_game_end
    update(last_action: @last_action, pending_answer: @pending_answer, wait_for_answer: @wait_for_answer, log: @log)
  end

  def handle_action_after_damage(current_player, damaged_player, defend_from)
    if current_player.draw_card_after_making_damage?(defend_from.type)
      draw_cards(current_player, 1)
    end

    if damaged_player.draw_card_after_receiving_damage?(defend_from.type)
      draw_cards(damaged_player, 1)
    end
  end

  def play_stop(character)
    index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
    player_to_receive_damage = pending_answer.delete_at index
    if pending_answer.blank?
      @pending_answer = nil
      @wait_for_answer = false
    end
    @last_action = "#{current_player.user.username} atacó a #{player_to_receive_damage.user.username} con #{defend_from.friendly_name} pero fue defendido."
    @log << { player: current_player.user.username, message: @last_action, type: :info }
    @discarded << player_to_receive_damage.discard_stop_card
    update(last_action: @last_action, pending_answer: @pending_answer, wait_for_answer: @wait_for_answer, discarded: @discarded, log: @log)
  end

  def respond_weapon(character, weapon_name)
    index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
    target = pending_answer.delete_at index
    if pending_answer.blank?
      @pending_answer = nil
      @wait_for_answer = false
    end
    @last_action = "#{target.user.username} descarto un arma: #{weapon_name.to_s.humanize}"
    @log << { player: current_player.user.username, message: @last_action, type: :info }
    @discarded << target.discard_card(weapon_name)
    update(last_action: @last_action, pending_answer: @pending_answer, wait_for_answer: @wait_for_answer, discarded: @discarded, log: @log)
  end

  def hanzo_ability(character, weapon_name)
    raise "Error, no eres hanzo" unless character == 'hanzo'
    index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
    target = pending_answer.delete_at index
    if pending_answer.blank?
      @pending_answer = nil
      @wait_for_answer = false
    end
    @last_action = "#{target.user.username} descarto un arma, #{weapon_name.to_s.humanize}, como parada"
    @log << { player: current_player.user.username, message: @last_action, type: :info }
    @discarded << target.discard_card(weapon_name)
    update(last_action: @last_action, pending_answer: @pending_answer, wait_for_answer: @wait_for_answer, discarded: @discarded, log: @log)
  end

  def defend_bushido(weapon_name)
    @last_action = "Descartó un arma, #{weapon_name.to_s.humanize}, por Bushido"
    @log << { player: current_player.user.username, message: @last_action, type: :info }
    @resolve_bushido = false
    @discarded << current_player.discard_card(weapon_name)
    transfer_bushido
    update(last_action: @last_action, pending_answer: @pending_answer, wait_for_answer: @wait_for_answer, discarded: @discarded, log: @log)
  end

  def handle_bushido
    if current_player.has_bushido?
      bushido_action_card = @deck.delete_at(0)
      @discarded << bushido_action_card
      if bushido_action_card.weapon?
        if current_player.has_weapon?
          @log << { player: current_player.user.username, message: "Salio arma resolviendo Bushido, descarta un arma o pierde uno de honor.", type: :info }
          @resolve_bushido = true
        else
          current_player.honor -= 1
          @discarded << current_player.discard_bushido
          @bushido_in_play = false
          @log << { player: current_player.user.username, message: "Pierde 1 honor debido a Bushido", type: :info }
          handle_game_end
        end
      else
        @log << { player: current_player.user.username, message: "Bushido - no salió arma, pasa al proximo", type: :info }
        transfer_bushido
      end
    end
  end

  def transfer_bushido
    next_player.visible_cards << current_player.discard_bushido
  end

  def reset_resistance_for_current_player
    current_player.reset_resistance
  end

  def next_player
    players[(@turn - 1) % @amount_players]
  end

  def next_phase
    return if @game_ended
    case @phase
    when 1
      @phase = 2
    when 2
      @phase = 3
    when 3
      if current_player.cards.size > 7
        @phase = 4
      else
        next_turn
        if current_player.resistance <= 0
          @phase = 1
        else
          @phase = 2
        end
      end
    when 4
      next_turn
      if current_player.resistance <= 0
        @phase = 1
      else
        @phase = 2
      end
    end
    handle_bushido if @phase == 2
    update phase: @phase, turn: @turn
  end
end
