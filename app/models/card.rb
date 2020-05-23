class Card
  WEAPON = :weapon
  PROPERTY = :property
  ACTION = :action
  TYPE = [WEAPON, PROPERTY, ACTION]
  WEAPONS = [
    :bo, :bo, :bo, :bo, :bo, :bokken, :bokken, :bokken, :bokken, :bokken, :bokken,
    :daikyu, :kanabo, :katana, :kiseru,  :kiseru, :kiseru, :kiseru, :kiseru, :kusarigama, :kusarigama, :kusarigama, :kusarigama,
    :nagayari, :naginata, :naginata, :nodachi, :shuriken, :shuriken, :shuriken, :tanegashima, :wakizashi
  ]

  CARDS = {
    bo: {
      type: :weapon,
      symbol: :origami,
      distance: 2,
      damage: 1,
      defend_with: :stop,
      count: 5
    },
    bokken: {
      type: :weapon,
      symbol: :origami,
      distance: 1,
      damage: 1,
      defend_with: :stop,
      count: 6
    },
    daikyu: {
      type: :weapon,
      symbol: :monte,
      distance: 5,
      damage: 2,
      defend_with: :stop,
      count: 1
    },
    kanabo: {
      type: :weapon,
      symbol: :origami,
      distance: 3,
      damage: 2,
      defend_with: :stop,
      count: 1
    },
    katana: {
      type: :weapon,
      symbol: :monte,
      distance: 2,
      defend_with: :stop,
      damage: 3,
      count: 1
    },
    kiseru: {
      type: :weapon,
      symbol: :origami,
      distance: 1,
      damage: 2,
      defend_with: :stop,
      count: 5
    },
    kusarigama: {
      type: :weapon,
      symbol: :origami,
      distance: 2,
      damage: 2,
      defend_with: :stop,
      count: 4
    },
    nagayari: {
      type: :weapon,
      symbol: :monte,
      distance: 4,
      damage: 2,
      defend_with: :stop,
      count: 1
    },
    naginata: {
      type: :weapon,
      symbol: :monte,
      distance: 4,
      damage: 1,
      defend_with: :stop,
      count: 2
    },
    nodachi: {
      type: :weapon,
      symbol: :monte,
      distance: 3,
      damage: 3,
      defend_with: :stop,
      count: 1
    },
    shuriken: {
      type: :weapon,
      symbol: :origami,
      distance: 3,
      damage: 1,
      defend_with: :stop,
      count: 3
    },
    tanegashima: {
      type: :weapon,
      symbol: :monte,
      distance: 5,
      damage: 1,
      defend_with: :stop,
      count: 1
    },
    wakizashi: {
      type: :weapon,
      symbol: :monte,
      distance: 1,
      damage: 3,
      defend_with: :stop,
      count: 1
    },
    armadura: {
      type: :property,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 4
    },
    bushido: {
      type: :property,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 2
    },
    concentracion: {
      type: :property,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 6
    },
    desenvainado_rapido: {
      type: :property,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 3
    },
    ceremonia_del_te: {
      type: :action,
      symbol: :templo,
      distance: 0,
      damage: 0,
      count: 4
    },
    daimio: {
      type: :action,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 3
    },
    distraccion: {
      type: :action,
      symbol: :koi,
      distance: 0,
      damage: 0,
      count: 5
    },
    geisha: {
      type: :action,
      symbol: :koi,
      distance: 0,
      damage: 0,
      count: 6
    },
    grito_de_batalla: {
      type: :action,
      symbol: :origami,
      distance: 0,
      damage: 1,
      count: 4
    },
    jiujitsu: {
      type: :action,
      symbol: :monte,
      distance: 0,
      damage: 1,
      count: 3
    },
    respiracion: {
      type: :action,
      symbol: :templo,
      distance: 0,
      damage: 0,
      count: 3
    },
    parada: {
      type: :action,
      symbol: :templo,
      distance: 0,
      damage: 0,
      count: 15
    }
  }

  EXPANSION_CARDS = {
    chigiriki: {
      type: :weapon,
      symbol: :origami,
      distance: 2,
      damage: 2,
      defend_with: :weapon,
      count: 2
    },
    jitte: {
      type: :weapon,
      symbol: :templo,
      distance: 1,
      damage: 2,
      defend_with: :stop,
      is_also: :parada,
      count: 2
    },
    kozuka: {
      type: :weapon,
      symbol: :origami,
      distance: 1,
      damage: 1,
      defend_with: :stop,
      returns_to_hand: true,
      count: 1
    },
    kusanagi: {
      type: :weapon,
      symbol: :monte,
      distance: 3,
      damage: 0,
      damage_based: :honor,
      defend_with: :stop,
      count: 1
    },
    makibishi: {
      type: :weapon,
      symbol: :origami,
      distance: 1,
      defend_with: :stop,
      damage: 1,
      damages_no_cards: true,
      count: 1
    },
    manrikigusari: {
      type: :weapon,
      symbol: :origami,
      distance: 3,
      damage: 1,
      discard_if_damaged: true,
      defend_with: :stop,
      count: 2
    },
    shigehtoyumi: {
      type: :weapon,
      symbol: :monte,
      distance: 9,
      damage: 1,
      defend_with: :stop,
      additional_weapon: true,
      count: 1
    },
    tanto: {
      type: :weapon,
      symbol: :monte,
      distance: 1,
      damage: 1,
      defend_with: :stop,
      count: 1
    },
    tessen: {
      type: :weapon,
      symbol: :templo,
      distance: 2,
      damage: 1,
      defend_with: :stop,
      is_also: :parada,
      count: 2
    },
    zen: {
      type: :weapon,
      symbol: :monte,
      distance: 9,
      damage: 0,
      damage_based: :property,
      defend_with: :stop,
      count: 3
    },
    ayudante: {
      type: :property,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 1
    },
    campesino: {
      type: :property,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 3
    },
    herida_sangrante: {
      type: :property,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 2
    },
    kote: {
      type: :property,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 1
    },
    maldicion: {
      type: :property,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 3
    },
    ceremonia_del_te: {
      type: :action,
      symbol: :templo,
      distance: 0,
      damage: 0,
      count: 5
    },
    ataque_simultaneo: {
      type: :action,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 2
    },
    contrataque: {
      type: :action,
      symbol: :templo,
      distance: 0,
      damage: 1,
      count: 2
    },
    geisha: {
      type: :action,
      symbol: :koi,
      distance: 0,
      damage: 0,
      count: 7
    },
    imitacion: {
      type: :action,
      symbol: :origami,
      distance: 0,
      damage: 0,
      count: 3
    },
    intuicion: {
      type: :action,
      symbol: :koi,
      distance: 0,
      damage: 0,
      count: 3
    },
    parada: {
      type: :action,
      symbol: :templo,
      distance: 0,
      damage: 0,
      count: 16
    }
  }

  attr_accessor :type, :name, :distance, :damage, :rkey, :already_damaged, :defend_with, :is_also, :symbol, :counter_attack_source

  def self.initialize_cards(expansion)
    cards = []
    cards_hash = expansion ? CARDS.merge(EXPANSION_CARDS) : CARDS
    cards_hash.map do |v, w|
      w[:count].times { |i| cards << Card.new(v, w, i) }
    end

    cards
  end

  def weapon?
    @type == :weapon
  end

  def friendly_name
    name.to_s.humanize + " (#{type})"
  end

  def return_card?
    name == :kozuka
  end

  def draw_additional_cards
    name == :ayudante ? 1 : 0
  end

  def add_honor_to_self?
    name == :tanto
  end

  def damage_modifier(target_player=nil)
    case name
    when :desenvainado_rapido
      1
    when :kusanagi
      target_player && target_player.honor || 0
    when :zen
      target_player && target_player.visible_cards.size || 0
    else
      0
    end
  end

  def damages_even_no_cards?
    name == :makibishi
  end

  def weapons_played_modifier
    case name
    when :concentracion
      1
    else
      0
    end
  end

  def distance_modifier
    case name
    when :armadura
      1
    else
      0
    end
  end

  def discard_if_damaged?
    name == :manrikigusari
  end

  def additional_weapon?
    name == :shigehtoyumi
  end

  def bushido?
    name == :bushido
  end

  def origami?
    symbol == :origami
  end

  def templo?
    symbol == :templo
  end

  def koi?
    symbol == :koi
  end

  def initialize(name, attrs, index)
    @name = name
    @type = attrs[:type]
    @distance = attrs[:distance]
    @damage = attrs[:damage]
    @rkey = "#{name}#{index}"
    @already_damaged = false
    @defend_with = attrs[:defend_with]
    @is_also = attrs[:is_also]
    @symbol = attrs[:symbol]
  end
end
