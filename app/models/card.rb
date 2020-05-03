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
      distance: 2,
      damage: 1,
      count: 5
    },
    bokken: {
      type: :weapon,
      distance: 1,
      damage: 1,
      count: 6
    },
    daikyu: {
      type: :weapon,
      distance: 5,
      damage: 2,
      count: 1
    },
    kanabo: {
      type: :weapon,
      distance: 3,
      damage: 2,
      count: 1
    },
    katana: {
      name: :katana,
      type: :weapon,
      distance: 2,
      damage: 3,
      count: 1
    },
    kiseru: {
      type: :weapon,
      distance: 1,
      damage: 2,
      count: 5
    },
    kusarigama: {
      type: :weapon,
      distance: 2,
      damage: 2,
      count: 4
    },
    nagayari: {
      type: :weapon,
      distance: 4,
      damage: 2,
      count: 1
    },
    naginata: {
      type: :weapon,
      distance: 4,
      damage: 1,
      count: 2
    },
    nodachi: {
      type: :weapon,
      distance: 3,
      damage: 3,
      count: 1
    },
    shuriken: {
      type: :weapon,
      distance: 3,
      damage: 1,
      count: 3
    },
    tanegashima: {
      type: :weapon,
      distance: 5,
      damage: 1,
      count: 1
    },
    wakizashi: {
      type: :weapon,
      distance: 1,
      damage: 3,
      count: 1
    },
    armadura: {
      type: :property,
      distance: 0,
      damage: 0,
      count: 4
    },
    bushido: {
      type: :property,
      distance: 0,
      damage: 0,
      count: 2
    },
    concentracion: {
      type: :property,
      distance: 0,
      damage: 0,
      count: 6
    },
    desenvainado_rapido: {
      type: :property,
      distance: 0,
      damage: 0,
      count: 3
    },
    ceremonia_del_te: {
      type: :action,
      distance: 0,
      damage: 0,
      count: 4
    },
    daimio: {
      type: :action,
      distance: 0,
      damage: 0,
      count: 3
    },
    distraccion: {
      type: :action,
      distance: 0,
      damage: 0,
      count: 5
    },
    geisha: {
      type: :action,
      distance: 0,
      damage: 0,
      count: 6
    },
    grito_de_batalla: {
      type: :action,
      distance: 0,
      damage: 1,
      count: 4
    },
    jiujitsu: {
      type: :action,
      distance: 0,
      damage: 1,
      count: 3
    },
    respiracion: {
      type: :action,
      distance: 0,
      damage: 0,
      count: 3
    },
    parada: {
      type: :action,
      distance: 0,
      damage: 0,
      count: 15
    }
  }

  attr_accessor :type, :name, :distance, :damage

  def self.initialize_cards
    cards = []
    CARDS.map do |v, w|
      w[:count].times { cards << Card.new(v, CARDS[v]) }
    end
    cards
  end

  def weapon?
    @type == :weapon
  end

  def friendly_name
    name.to_s.humanize + " (#{type})"
  end

  def damage_modifier
    case name
    when :desenvainado_rapido
      1
    else
      0
    end
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

  def initialize(name, attrs)
    @name = name
    @type = attrs[:type]
    @distance = attrs[:distance]
    @damage = attrs[:damage]
  end
end
